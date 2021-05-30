package com.example.sensorscollector2.collector.consumer

import android.os.Handler
import android.os.Message
import com.example.sensorscollector2.collector.DataEvent

class HandlerConsumer(private val handler: Handler): ISensorEventConsumer {
    override fun consume(event: DataEvent) {
        val msg = Message()
        msg.obj = event
        handler.sendMessage(msg)
    }
}