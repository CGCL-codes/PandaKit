package com.example.sensorscollector2.collector

import android.util.Log
import com.example.sensorscollector2.collector.consumer.ISensorEventConsumer
import java.util.concurrent.BlockingQueue
import java.util.concurrent.CyclicBarrier

class SensorEventConsumerThread(
    val queue: BlockingQueue<DataEvent>,
    val barrier: CyclicBarrier,
    val consumers: List<ISensorEventConsumer>
) : Runnable {
    override fun run() {
        barrier.await()

        try {
            while(!Thread.currentThread().isInterrupted) {
                val event = queue.take()
                for(consumer in consumers)
                    consumer.consume(event)
//                Log.d(TAG, "${event.sensor.type} ${event.values[0]} ${event.sensor.name} ${event.timestamp}")
                // non-blocking approach, which is not used
//                val event = queue.poll()
//                if(event == null) {
//                    Log.w(TAG, "queue is empty")
//                    Thread.sleep(100)
//                } else {
//                    Log.d(TAG, "got a sensor event from queue")
//                }
            }
        } catch (e : InterruptedException) {
            Log.d("ConsumerThread", "consumer interrupted and will exit")
            e.printStackTrace()
        } finally {
            Log.d("ConsumerThread", "consumer is exiting")
            queue.clear()
        }
    }
}