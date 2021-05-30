package com.example.sensorscollector2.pdr.heading

import com.example.sensorscollector2.collector.DataEvent

interface IOrientationDetector {
    fun updateWithDataEvent(event : DataEvent): DataEvent?
    fun getOrientation() : FloatArray
    fun lastOrientationTimestamp() : Long
}