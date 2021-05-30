package com.example.sensorscollector2.collector.consumer

import com.example.sensorscollector2.Utils.GeneratedType
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.collector.generated2misc
import com.example.sensorscollector2.collector.sensor2misc
import com.example.sensorscollector2.collector.writeDataEventToFile
import okio.buffer
import okio.sink
import java.io.File

class WriteToFileConsumer(private val dataDir: File): ISensorEventConsumer {
    override fun consume(event: DataEvent) {
        writeDataEventToFile(event, dataDir)
    }

    companion object {

        fun createDataDir(dir: File) {
            if(!dir.exists())
                dir.mkdirs()
        }

        fun createFiles(sensorList: List<Int>, createBleFile: Boolean, dataDir: File) {
            for(misc in sensor2misc) {
                if(misc.key in sensorList) {
                    val file = File(dataDir, "${misc.value.name}.csv")
                    file.sink(append = true).buffer().use { sink ->
                        sink.writeUtf8(misc.value.firstLine)
                        sink.writeUtf8("\n")
                    }
                }
            }

            // create file for ble scan result
            if(createBleFile) {
                val file = File(dataDir, "ble_ibeacon.csv")
                file.sink(append = true).buffer().use { sink ->
                    sink.writeUtf8("major,minor,rssi,timestamp\n")
                }
            }
        }

        fun createMetadata(meta: List<Pair<String, String>>, dataDir: File) {
            val fileMetadata = File(dataDir, "metadata.csv")
            fileMetadata.sink(append = true).buffer().use { sink ->
                for((idx, key) in meta.map { p -> p.first }.withIndex()) {
                    if(idx != 0) sink.writeUtf8(",")
                    sink.writeUtf8(key)
                }
                sink.writeUtf8("\n")
                for((idx, value) in meta.map { p -> p.second }.withIndex()) {
                    if(idx != 0) sink.writeUtf8(",")
                    sink.writeUtf8(value)
                }
            }
        }

        fun createGeneratedFiles(generatedList: List<GeneratedType>, dataDir: File) {
            val dir = File(dataDir, "generated")
            createDataDir(dir)

            for(gen in generatedList) {
                val misc = generated2misc[gen] ?: continue
                val file = File(dir, "${misc.name}.csv")
                if(file.exists()) continue
                file.sink(append = true).buffer().use { sink ->
                    sink.writeUtf8(misc.firstLine)
                    sink.writeUtf8("\n")
                }
            }
        }
    }
}