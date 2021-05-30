package com.example.sensorscollector2.pdr.stride

import com.example.sensorscollector2.collector.DataEvent

interface IStrideStrategy {
    fun updateWithDataEvent(event : DataEvent) = Unit
    fun getStrideLength(): Float
    fun getLastStrideTimestamp() = 0
}