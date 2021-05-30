package com.example.sensorscollector2.collector.consumer

import com.example.sensorscollector2.collector.DataEvent

interface ISensorEventConsumer {
    fun consume(event: DataEvent)
}