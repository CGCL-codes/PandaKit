package com.example.sensorscollector2.collector

import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Environment
import android.os.IBinder
import android.os.SystemClock
import android.util.Log
import androidx.preference.PreferenceManager
import com.example.sensorscollector2.Utils.getTimeStringFromCurrentTimeMillis
import com.example.sensorscollector2.activity.CollectorActivity
import com.example.sensorscollector2.collector.consumer.WriteToFileConsumer
import com.example.sensorscollector2.model.BleEvent
import com.example.sensorscollector2.model.TYPE_BLE_EVENT
import com.example.sensorscollector2.model.TYPE_SENSOR_EVENT
import com.neovisionaries.bluetooth.ble.advertising.ADPayloadParser
import com.neovisionaries.bluetooth.ble.advertising.IBeacon
import okio.IOException
import java.io.File
import java.util.*
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.CyclicBarrier

class SensorsCollectorService : Service(), SensorEventListener {

    private val TAG = "SensorsCollectorService"

    private lateinit var prefs : SharedPreferences

    private lateinit var sensorManager: SensorManager

    private val sensorEventQueue = ArrayBlockingQueue<DataEvent>(256)

    private lateinit var consumer : Thread

    private lateinit var supportedSensors : List<Int>
    private lateinit var carryType : String
    private lateinit var environment : String
    private lateinit var speedLevel : String
    private var sensorDelay = 0

    private lateinit var dir: File

    private var startTimeMills: Long = 0

    private var totalSensorEventCount = 0
    private var totalBeaconEventCount = 0
    private var totalBleEventCount = 0
    private var discardedEventCount = 0

    private val bluetoothAdapter: BluetoothAdapter? by lazy(LazyThreadSafetyMode.NONE) {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothManager.adapter
    }
    private val BluetoothAdapter.isDisabled: Boolean
        get() = !isEnabled


    override fun onCreate() {
        super.onCreate()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        prefs = PreferenceManager.getDefaultSharedPreferences(this)
        Log.d(TAG, "service created")
    }

    @Throws(IOException::class)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        getPreferences()
        getSupportedSensors()
        val guid = getGuid()

        Log.d(TAG, supportedSensors.joinToString { it.toString() })

        Log.d(TAG, "context settings: carryType=$carryType environment=$environment speedLevel=$speedLevel")
        Log.d(TAG, "sensor  settings: sensorDelay=$sensorDelay")

        val currentTimeMillis = System.currentTimeMillis()
        val elapsedRealTimeNanos = SystemClock.elapsedRealtimeNanos()
        startTimeMills = currentTimeMillis

        dir = File(getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), "$currentTimeMillis")
        if(!dir.exists()) dir.mkdirs()

        WriteToFileConsumer.createMetadata(
            meta = arrayListOf(
                Pair("currentTimeMillis", currentTimeMillis.toString()),
                Pair("elapsedRealTimeNanos", elapsedRealTimeNanos.toString()),
                Pair("guid", guid),
                Pair("carryType", carryType),
                Pair("environment", environment),
                Pair("speedLevel", speedLevel),
                Pair("sensorDelay", sensorDelay.toString())
            ),
            dir
        )

        createFiles(dir)

        // register supported sensors
        for(sensor in supportedSensors) {
            sensorManager.getDefaultSensor(sensor)?.also { defaultSensor ->
                sensorManager.registerListener(this, defaultSensor, sensorDelay)
            }
        }

        // start ble scan
        val scanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setReportDelay(0L)
            .build()
        val scanner = bluetoothAdapter?.bluetoothLeScanner
        if(scanner != null) {
            Log.d(TAG, "scan started")
            scanner.startScan(null, scanSettings, scanCallback)

        } else {
            Log.e(TAG, "could not get ble scanner")
        }

        Log.d(TAG, "on start command")

        // launch consumer thread
        val barrier = CyclicBarrier(2)
        consumer = Thread(SensorCollectorConsumer(sensorEventQueue, barrier, dir))
        consumer.start()
        barrier.await()

        sendBroadcastToCollector(CollectorActivity.COLLECTOR_GOT_INFO, "start at: ${getTimeStringFromCurrentTimeMillis(currentTimeMillis)}")
        sendBroadcastToCollector(CollectorActivity.COLLECTOR_IS_COLLECTING, "")

        return super.onStartCommand(intent, flags, startId)
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
        consumer.interrupt()

        val newDir = File(getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS),
            getTimeStringFromCurrentTimeMillis(startTimeMills)
        )
        dir.renameTo(newDir)

        sendBroadcastToCollector(CollectorActivity.COLLECTOR_IS_READY, "")
        sendBroadcastToCollector(CollectorActivity.COLLECTOR_GOT_INFO, "total sensor event: $totalSensorEventCount")
        sendBroadcastToCollector(CollectorActivity.COLLECTOR_GOT_INFO, "total beacon event: $totalBeaconEventCount")
        sendBroadcastToCollector(CollectorActivity.COLLECTOR_GOT_INFO, "discarded event: $discardedEventCount")
        sendBroadcastToCollector(CollectorActivity.COLLECTOR_GOT_INFO, "finished at: ${getTimeStringFromCurrentTimeMillis(System.currentTimeMillis())}\n\nready for next collecting")
        Log.d(TAG, "ble event count: $totalBleEventCount")

        Log.d(TAG, "service destroyed")
    }

    override fun onBind(p0: Intent?): IBinder? {
        TODO("Not yet implemented")
    }

    override fun onSensorChanged(event: SensorEvent?) {
//        Log.v(TAG, "sensor changed")
        if(event == null) return
        totalSensorEventCount++
        if(!sensorEventQueue.offer(DataEvent(TYPE_SENSOR_EVENT, event))) {
            discardedEventCount++
            Log.w(TAG, "queue is full, event discarded")
        }
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
        // do nothing
    }

    private fun getGuid() : String {
        var guid = prefs.getString("guid", "").toString()
        if(guid.isEmpty()) {
            guid = UUID.randomUUID().toString()
            prefs.edit().apply {
                putString("guid", guid)
                apply()
            }
        }
        return guid
    }

    private fun getPreferences() {
        supportedSensors = getSupportedSensors()

        carryType = prefs.getString("carry_type", "hand").toString()
        environment = prefs.getString("environment", "lab").toString()
        speedLevel = prefs.getString("speed_level", "fast").toString()
        sensorDelay = prefs.getString("sensor_delay", "0")?.toInt() ?: 0

        Log.d(TAG, "got prefs")
    }

    /*
     * the following sensors will be filtered out
     *
     * TYPE_SIGNIFICANT_MOTION = 17;
     *
     * TYPE_TILT_DETECTOR = 22;
     * TYPE_WAKE_GESTURE = 23;
     * TYPE_GLANCE_GESTURE = 24;
     * TYPE_PICK_UP_GESTURE = 25;
     * TYPE_WRIST_TILT_GESTURE = 26;
     *
     * deprecated in api level 15:
     * TYPE_ORIENTATION = 3;
     *
     * require api level 26
     * TYPE_ACCELEROMETER_UNCALIBRATED = 35;
     *
     * type > 65535 may be a customized sensor, which will be filtered out
     */
    private fun getSupportedSensors() : List<Int> {
        val deviceSensors = sensorManager.getSensorList(Sensor.TYPE_ALL)
        return deviceSensors.filterNotNull()
                .map { sensor -> sensor.type }
//                .filter { type -> type < 65535 && type != 17 && type != 3 && type != 35 && type !in 22..26 }
                .filter { type -> type in sensor2misc.keys }
    }

    private fun createFiles(dataDir: File) {
        WriteToFileConsumer.createFiles(
            sensorList =  sensor2misc.keys.filter { it in supportedSensors },
            createBleFile = true,
            dataDir
        )
    }

    private fun sendBroadcastToCollector(what: Int, info: String) {
        val intent = Intent("$packageName.COLLECTOR_RECEIVER")
        intent.putExtra("what", what)
        intent.putExtra("info", info)
        sendBroadcast(intent)
    }


    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            totalBleEventCount++
//            Log.d(TAG, "onScanResult")
            if(result != null && result.scanRecord != null) {
                val structures = ADPayloadParser.getInstance().parse(result.scanRecord!!.bytes)
                for(structure in structures) {
                    if(structure is IBeacon) {
                        Log.d(
                            "BleBeacon",
                            "${structure.uuid} ${structure.major} ${structure.minor} ${structure.power}"
                        )
                        val event = DataEvent(TYPE_BLE_EVENT, BleEvent(result, structure.major, structure.minor))
                        totalBeaconEventCount++
                        if(!sensorEventQueue.offer(event)) {
                            discardedEventCount++
                            Log.w(TAG, "queue is full, event discarded")
                        }

                    }
                }
            } else {
                Log.w(TAG, "got a strange result")
            }
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            Log.d(TAG, "onBatch")
        }

        override fun onScanFailed(errorCode: Int) {
            Log.d(TAG, "onFailure")
        }
    }
}