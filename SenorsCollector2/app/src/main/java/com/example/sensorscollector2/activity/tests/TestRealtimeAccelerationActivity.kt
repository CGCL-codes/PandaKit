package com.example.sensorscollector2.activity.tests

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.sensorscollector2.Utils.registerSensors
import com.example.sensorscollector2.databinding.ActivityTestRealtimeAccelerationBinding
import kotlin.math.sqrt

class TestRealtimeAccelerationActivity : AppCompatActivity(), SensorEventListener {

    private lateinit var binding : ActivityTestRealtimeAccelerationBinding
    private lateinit var sensorManager: SensorManager

//    private var mAccelerometer: Sensor? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTestRealtimeAccelerationBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
//        mAccelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)
    }

    override fun onResume() {
        super.onResume()
//        mAccelerometer?.also { sensor ->
//            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
//        }
        registerSensors(
            listOf(
                Sensor.TYPE_ACCELEROMETER,
                Sensor.TYPE_GRAVITY,
                Sensor.TYPE_LINEAR_ACCELERATION
            ),
            sensorManager,
            this,
            SensorManager.SENSOR_DELAY_NORMAL
        )
    }

    override fun onPause() {
        super.onPause()
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event != null) {
            when(event.sensor.type) {
                Sensor.TYPE_LINEAR_ACCELERATION -> {
                    binding.testLinearAccelerationText.text = getTextString(event)
                }
                Sensor.TYPE_GRAVITY -> {
                    binding.testGravityText.text = getTextString(event)
                }
                Sensor.TYPE_ACCELEROMETER -> {
                    binding.testAccelerationText.text = getTextString(event)
                }
            }
        }
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {

    }

    private fun getTextString(event: SensorEvent) : String {
        return "x: ${event.values[0]}\ny: ${event.values[1]}\nz: ${event.values[2]}\n" +
                "magnitude: ${sqrt(event.values[0]*event.values[0] + event.values[1]*event.values[1] + event.values[2]*event.values[2])}"
    }
}