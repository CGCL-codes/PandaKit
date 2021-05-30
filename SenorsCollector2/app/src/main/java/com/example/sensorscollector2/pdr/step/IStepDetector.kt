package com.example.sensorscollector2.pdr.step

import com.example.sensorscollector2.collector.DataEvent

interface IStepDetector {
    fun updateWithDataEvent(event : DataEvent): DataEvent?
    fun isStepDetected() : Boolean
    fun lastDetectedTimestamp() : Long
}