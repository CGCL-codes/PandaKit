package com.example.sensorscollector2.collector

import android.util.Log
import java.io.File
import java.util.concurrent.BlockingQueue
import java.util.concurrent.CyclicBarrier

class SensorCollectorConsumer(private val queue: BlockingQueue<DataEvent>, private val barrier: CyclicBarrier, private val dataDir: File) : Runnable {

    companion object {
        const val TAG = "SensorEventConsumer"
    }

    override fun run() {
        barrier.await()

        try {
            while(!Thread.currentThread().isInterrupted) {
                val event = queue.take()
                writeDataEventToFile(event, dataDir)
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
            Log.d(TAG, "consumer interrupted and will exit")
            e.printStackTrace()
        } finally {
            Log.d(TAG, "consumer is exiting")
            queue.clear()
        }
    }
}