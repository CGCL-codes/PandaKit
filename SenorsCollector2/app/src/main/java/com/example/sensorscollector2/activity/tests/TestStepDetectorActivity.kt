package com.example.sensorscollector2.activity.tests

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.example.sensorscollector2.R
import com.example.sensorscollector2.Utils.registerSensors
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.databinding.ActivityTestStepDetectorBinding
import com.example.sensorscollector2.model.TYPE_SENSOR_EVENT
import com.example.sensorscollector2.pdr.step.IStepDetector
import com.example.sensorscollector2.pdr.step.StaticAccMagnitudeStepDetector

class TestStepDetectorActivity : AppCompatActivity(), SensorEventListener {

    private lateinit var binding: ActivityTestStepDetectorBinding
    private lateinit var sensorManager: SensorManager
    private lateinit var stepDetector: IStepDetector
    private var stepCnt = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTestStepDetectorBinding.inflate(layoutInflater)
        setContentView(binding.root)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepDetector = StaticAccMagnitudeStepDetector()
    }

    override fun onResume() {
        super.onResume()
        registerSensors(
            listOf(
                Sensor.TYPE_ACCELEROMETER
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
        val e = stepDetector.updateWithDataEvent(DataEvent(TYPE_SENSOR_EVENT, event))
            ?:return
        if(stepDetector.isStepDetected()) {
            stepCnt++
            binding.stepCount.text = stepCnt.toString()
        }
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {

    }
}