package com.example.sensorscollector2.pdr.step

import android.hardware.Sensor
import android.hardware.SensorEvent
import com.example.sensorscollector2.Utils.GeneratedType
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.model.GeneratedEvent
import com.example.sensorscollector2.model.TYPE_GENERATED_EVENT
import kotlin.math.sqrt

class StaticAccMagnitudeStepDetector(
    private val upperThreshold: Float = 10.8f,
    private val lowerThreshold: Float = 8.8f
): IStepDetector {

    private var detected = false
    private var consumed = true
    private var lastTimestamp: Long = 0

    override fun updateWithDataEvent(event: DataEvent): DataEvent? {
        when(event.event) {
            is SensorEvent -> {
                val sensorEvent = event.event
                if(sensorEvent.sensor.type != Sensor.TYPE_ACCELEROMETER)
                    return null

                val magnitude = getMagnitude(sensorEvent.values)

                if(!detected) {
                    if(magnitude > upperThreshold) {
                        detected = true
                        consumed = false
                        lastTimestamp = sensorEvent.timestamp
                    }
                } else if(magnitude < lowerThreshold) {
                    detected = false
                }

                if(detected && !consumed)
                    return DataEvent(
                        TYPE_GENERATED_EVENT,
                        GeneratedEvent(
                            GeneratedType.Gen_Step_Detector,
                            FloatArray(0),
                            sensorEvent.timestamp
                        )
                    )
            }
        }
        return null
    }

    override fun isStepDetected(): Boolean {
        if(detected && !consumed) {
            consumed = true
            return true
        }
        return false
    }

    override fun lastDetectedTimestamp(): Long {
        return lastTimestamp
    }

    private fun getMagnitude(vector: FloatArray): Float {
        var squareSum = 0f
        for(a in vector)
            squareSum += a*a
        return sqrt(squareSum)
    }
}