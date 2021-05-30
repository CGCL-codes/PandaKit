package com.example.sensorscollector2.activity.tests

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.sensorscollector2.Utils.registerSensors
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.databinding.ActivityTestOrientationBinding
import com.example.sensorscollector2.model.GeneratedEvent
import com.example.sensorscollector2.model.TYPE_SENSOR_EVENT
import com.example.sensorscollector2.pdr.heading.IOrientationDetector
import com.example.sensorscollector2.pdr.heading.MagneticOrientation

class TestOrientationActivity : AppCompatActivity(), SensorEventListener {

    private lateinit var binding: ActivityTestOrientationBinding
    private lateinit var sensorManager: SensorManager
    private lateinit var orientationDetector: IOrientationDetector

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTestOrientationBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        orientationDetector = MagneticOrientation()
    }

    override fun onResume() {
        super.onResume()
        registerSensors(
            listOf(
//                Sensor.TYPE_GRAVITY,
                Sensor.TYPE_MAGNETIC_FIELD,
                Sensor.TYPE_ACCELEROMETER,
//                Sensor.TYPE_MAGNETIC_FIELD_UNCALIBRATED
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
        if(event == null) return
        val e = orientationDetector.updateWithDataEvent(DataEvent(TYPE_SENSOR_EVENT, event))
            ?: return
        val gen = e.event as GeneratedEvent
        binding.testRotationAnglesText.text = getTextString(gen.data)
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {
        // do nothing
    }


    private fun getTextString(data: FloatArray): String {
        return data.map { it*180f/Math.PI }.joinToString("\n") { String.format("%.2f", it) }
    }
}