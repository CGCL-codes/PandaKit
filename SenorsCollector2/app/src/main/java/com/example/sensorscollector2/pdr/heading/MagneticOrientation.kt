package com.example.sensorscollector2.pdr.heading

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import com.example.sensorscollector2.Utils.GeneratedType
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.model.GeneratedEvent
import com.example.sensorscollector2.model.TYPE_GENERATED_EVENT

class MagneticOrientation : IOrientationDetector{

    private val TAG = "MagneticOrientation"

    private var lastTimestamp: Long = 0

    private var mag: FloatArray? = null
    private var lastMagTimestamp: Long = 0

    private var acc: FloatArray? = null
    private var lastAccTimestamp: Long = 0

    private val rotationMatrix = FloatArray(9)
    private val rotationAngles = FloatArray(3)

    private var ready = false

    override fun updateWithDataEvent(event: DataEvent): DataEvent? {
        when(event.event) {
            is SensorEvent -> {
                val sensorEvent = event.event
                when(sensorEvent.sensor.type) {
                    Sensor.TYPE_ACCELEROMETER -> {
                        acc = sensorEvent.values
                        lastAccTimestamp = sensorEvent.timestamp
                    }
                    Sensor.TYPE_MAGNETIC_FIELD -> {
//                        Log.v(TAG, "mag")
                        mag = sensorEvent.values
                        lastMagTimestamp = sensorEvent.timestamp

                        if(lastAccTimestamp != 0L) {
                            SensorManager.getRotationMatrix(rotationMatrix, null, acc, mag)
                            SensorManager.getOrientation(rotationMatrix, rotationAngles)
                            lastTimestamp = sensorEvent.timestamp

                            ready = true

                            return DataEvent(
                                TYPE_GENERATED_EVENT,
                                GeneratedEvent(
                                    GeneratedType.Gen_Rotation_Angles,
                                    rotationAngles,
                                    sensorEvent.timestamp
                                )
                            )
//                            ready = true
                        }
                    }
                }
            }
        }
        return null
    }

    override fun getOrientation(): FloatArray {
        return if (ready) {
            rotationAngles
        } else {
            FloatArray(0)
        }

    }

    override fun lastOrientationTimestamp(): Long {
        return lastTimestamp
    }
}