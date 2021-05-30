package com.example.sensorscollector2.activity

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import com.example.sensorscollector2.R
import com.example.sensorscollector2.collector.SensorsCollectorService
import com.example.sensorscollector2.databinding.ActivityCollectorBinding

class CollectorActivity : AppCompatActivity() {

    private val TAG = "CollectorActivity"

    private val REQUEST_ENABLE_BT = 0x1234

    private lateinit var binding : ActivityCollectorBinding

    private var isReady = true
    private var isCollecting = false

    private lateinit var receiver : CollectorReceiver

    private val bluetoothAdapter: BluetoothAdapter? by lazy(LazyThreadSafetyMode.NONE) {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothManager.adapter
    }
    private val BluetoothAdapter.isDisabled: Boolean
        get() = !isEnabled

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCollectorBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.mainToolBar)

        Log.d(TAG, "creating at ${Thread.currentThread()}")

//        binding.startCollectButton.setOnClickListener {
//            val intent = Intent(this, SensorsCollectorService::class.java)
//            startService(intent)
//        }

//        binding.endTester.setOnClickListener {
//            val intent = Intent(this, SensorsCollectorService::class.java)
//            stopService(intent)
//        }

        bluetoothAdapter?.takeIf { it.isDisabled }?.apply {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
        }

        binding.collectorFab.setOnClickListener { fab ->
            if(isReady) {
                isReady = false

                fab.isEnabled = false
                binding.collectorFab.setImageResource(android.R.drawable.ic_popup_sync)

                binding.collectorText.text = ""

                val intent = Intent(this, SensorsCollectorService::class.java)
                startService(intent)

            } else if(isCollecting) {
                isCollecting = false
                fab.isEnabled = false
                binding.collectorFab.setImageResource(android.R.drawable.ic_popup_sync)
                val intent = Intent(this, SensorsCollectorService::class.java)
                stopService(intent)
            }
        }
    }

    override fun onResume() {
        super.onResume()

        val intentFilter = IntentFilter()
        intentFilter.addAction("$packageName.COLLECTOR_RECEIVER")
        receiver = CollectorReceiver()
        registerReceiver(receiver, intentFilter)
    }

    override fun onPause() {
        super.onPause()
        unregisterReceiver(receiver)
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.maintoolbar, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when(item.itemId) {
            R.id.preferences -> {
                val intent = Intent(this, SettingsActivity::class.java)
                startActivity(intent)
            }
        }
        return true
    }


    inner class CollectorReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if(intent == null) return
            val what = intent.getIntExtra("what", 0)
            val info = intent.getStringExtra("info")

            when(what) {
                COLLECTOR_IS_COLLECTING -> {
                    isCollecting = true
                    binding.collectorFab.setImageResource(android.R.drawable.ic_media_pause)
//                    binding.collectorFab.setImageDrawable(null)
//                    binding.collectorFab.backgroundTintList = ColorStateList.valueOf(0)
                    binding.collectorFab.isEnabled = true
                    binding.collectorText.append("collecting...\n")
                }
                COLLECTOR_IS_READY -> {
                    isReady = true
                    binding.collectorFab.setImageResource(android.R.drawable.ic_media_play)
                    binding.collectorFab.isEnabled = true
                    binding.collectorText.append("done\n")
                }
                COLLECTOR_GOT_INFO -> {
                    if(info != null) {
                        binding.collectorText.append("$info\n")
                    }
                }
            }

        }
    }

    companion object {
        const val COLLECTOR_IS_COLLECTING = 0XCAFE
        const val COLLECTOR_IS_READY = 0xBABE
        const val COLLECTOR_GOT_INFO = 0xABCD
//        val COLLECTOR_SERVICE_OVER = 0X8531
//        val COLLECTOR_CONSUMER_OVER = 0X8432
    }
}