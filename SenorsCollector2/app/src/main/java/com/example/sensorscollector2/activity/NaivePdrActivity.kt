package com.example.sensorscollector2.activity

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.os.Environment
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.example.sensorscollector2.Utils.registerSensors
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.collector.SensorEventConsumerThread
import com.example.sensorscollector2.collector.consumer.NaivePdrConsumer
import com.example.sensorscollector2.collector.consumer.WriteToFileConsumer
import com.example.sensorscollector2.databinding.ActivityNaivePdrBinding
import com.example.sensorscollector2.model.TYPE_SENSOR_EVENT
import com.example.sensorscollector2.pdr.heading.MagneticOrientation
import com.example.sensorscollector2.pdr.step.StaticAccMagnitudeStepDetector
import com.example.sensorscollector2.pdr.stride.FixedStrideLengthStrategy
import java.io.File
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.CyclicBarrier

class NaivePdrActivity : AppCompatActivity(), SensorEventListener {

    private val TAG = "NaivePdrActivity"

    private lateinit var binding : ActivityNaivePdrBinding
    private lateinit var sensorManager: SensorManager

    private lateinit var dir: File
    private lateinit var pdrThread: Thread

    private val dataEventQueue = ArrayBlockingQueue<DataEvent>(256)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNaivePdrBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    override fun onResume() {
        super.onResume()

        val currentTimeMillis = System.currentTimeMillis()
//        val elapsedRealTimeNanos = SystemClock.elapsedRealtimeNanos()

        // create files
        dir = File(getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), "$currentTimeMillis")
        WriteToFileConsumer.createDataDir(dir)
        WriteToFileConsumer.createMetadata(arrayListOf(
            // TODO: 2021/2/16
        ), dir)
        WriteToFileConsumer.createFiles(sensorList, false, dir)
        WriteToFileConsumer.createGeneratedFiles(NaivePdrConsumer.generatedList, dir)

        registerSensors(sensorList, sensorManager, this)

        val barrier = CyclicBarrier(2)

        pdrThread = Thread(SensorEventConsumerThread(
            queue = dataEventQueue,
            barrier = barrier,
            consumers = arrayListOf(
                WriteToFileConsumer(dir),
                NaivePdrConsumer(
                    stepDetector =  StaticAccMagnitudeStepDetector(),
                    orientationDetector = MagneticOrientation(),
                    strideLengthStrategy = FixedStrideLengthStrategy(0.5F),
                    followingConsumers =  arrayListOf(
                        WriteToFileConsumer(dir)
                    )
                )
            )
        ))
        pdrThread.start()

        barrier.await()
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)

        pdrThread.interrupt()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if(event == null) return
        if(!dataEventQueue.offer(DataEvent(TYPE_SENSOR_EVENT, event))) {
            Log.w(TAG, "queue is full, event discarded")
        }
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
    }

    companion object {
        val sensorList = arrayListOf(
            Sensor.TYPE_ACCELEROMETER,
            Sensor.TYPE_MAGNETIC_FIELD
        )
    }
}