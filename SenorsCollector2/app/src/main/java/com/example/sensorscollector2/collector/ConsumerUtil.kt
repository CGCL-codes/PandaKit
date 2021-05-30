package com.example.sensorscollector2.collector

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.util.Log
import com.example.sensorscollector2.Utils.GeneratedType
import com.example.sensorscollector2.model.BleEvent
import com.example.sensorscollector2.model.GeneratedEvent
import okio.buffer
import okio.sink
import java.io.File

fun writeDataEventToFile(event: DataEvent, dataDir: File) {
//    Log.v("consumer", "got a sensor event")
    when(event.event) {
        is SensorEvent -> {
            writeSensorEventToFile(event.event, dataDir)
        }
        is BleEvent -> {
            writeBleEventToFile(event.event, dataDir)
        }
        is GeneratedEvent -> {
            writeGeneratedEventToFile(event.event, dataDir)
        }
    }
}

fun writeSensorEventToFile(event: SensorEvent, dataDir: File) {
    if(event.sensor.type in sensor2misc.keys) {
        val misc = sensor2misc[event.sensor.type] ?: return
        val file = File(dataDir, "${misc.name}.csv")
        file.sink(append = true).buffer().use { sink ->
            if(misc.size > 0) {
                repeat(misc.size) { i ->
                    sink.writeUtf8("${event.values[i]}")
                    sink.writeUtf8(",")
                }
            }

            sink.writeUtf8("${event.timestamp}")
            sink.writeUtf8("\n")
        }
    } else {
        Log.w("writeToFile", "got a strange sensor event with type: ${event.sensor.type}(${event.sensor.name})")
    }
}

data class SensorMisc(val name: String, val firstLine: String, val size: Int)

val sensor2misc = mapOf(
        Pair(Sensor.TYPE_ACCELEROMETER, SensorMisc("accelerometer", "x,y,z,timestamp", 3)),
        // accelerator_uncalibrated
//        Pair(Sensor.TYPE_ACCELEROMETER_UNCALIBRATED, SensorMisc("accelerometer_uncalibrated", "x,y,z,xc,yc,zc,timestamp")),
        Pair(Sensor.TYPE_GRAVITY, SensorMisc("gravity", "x,y,z,timestamp", 3)),
        Pair(Sensor.TYPE_GYROSCOPE, SensorMisc("gyroscope", "x,y,z,timestamp", 3)),
        Pair(Sensor.TYPE_GYROSCOPE_UNCALIBRATED, SensorMisc("gyroscope_uncalibrated", "x,y,z,xc,yc,zc,timestamp", 6)),
        Pair(Sensor.TYPE_LINEAR_ACCELERATION, SensorMisc("linear_acceleration", "x,y,z,timestamp", 3)),
        Pair(Sensor.TYPE_ROTATION_VECTOR, SensorMisc("rotation_vector", "x,y,z,s,timestamp", 4)),
        Pair(Sensor.TYPE_STEP_COUNTER, SensorMisc("step_counter", "count,timestamp", 1)),
        Pair(Sensor.TYPE_STEP_DETECTOR, SensorMisc("step_detector", "timestamp", 0)),
        Pair(Sensor.TYPE_GAME_ROTATION_VECTOR, SensorMisc("game_rotation_vector", "x,y,z,timestamp", 3)),
        Pair(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR, SensorMisc("geomagnetic_rotation_vector", "x,y,z,timestamp", 3)),
        Pair(Sensor.TYPE_MAGNETIC_FIELD, SensorMisc("magnetic_field", "x,y,z,timestamp", 3)),
        Pair(Sensor.TYPE_MAGNETIC_FIELD_UNCALIBRATED, SensorMisc("magnetic_field_uncalibrated", "x,y,z,xc,yc,zc,timestamp", 3)),
        Pair(Sensor.TYPE_PROXIMITY, SensorMisc("proximity", "d,timestamp", 1)),
        Pair(Sensor.TYPE_AMBIENT_TEMPERATURE, SensorMisc("ambient_temperature", "temperature,timestamp", 1)),
        Pair(Sensor.TYPE_LIGHT, SensorMisc("light", "light,timestamp", 1)),
        Pair(Sensor.TYPE_PRESSURE, SensorMisc("pressure", "pressure,timestamp", 1)),
        Pair(Sensor.TYPE_RELATIVE_HUMIDITY, SensorMisc( "relative_humidity","humidity,timestamp", 1))
// wifi and ble are not here
)

fun writeBleEventToFile(event: BleEvent, dataDir: File) {
    val file = File(dataDir, "ble_ibeacon.csv")
    file.sink(append = true).buffer().use { sink ->
        sink.writeUtf8("${event.major}")
        sink.writeUtf8(",")
        sink.writeUtf8("${event.minor}")
        sink.writeUtf8(",")
        sink.writeUtf8("${event.scanResult.rssi}")
        sink.writeUtf8(",")
        sink.writeUtf8("${event.scanResult.timestampNanos}")
        sink.writeUtf8("\n")
    }
}

val generated2misc = mapOf(
    Pair(
        GeneratedType.Gen_Step_Detector,
        SensorMisc("step_detector", "timestamp", 0)
    ),
    Pair(
        GeneratedType.Gen_Rotation_Angles,
        SensorMisc("rotation_angles", "azimuth,pitch,roll,timestamp", 3)
    ),
    Pair(
        GeneratedType.Gen_Trajectory,
        SensorMisc("trajectory", "x,y,timestamp", 2)
    )
)

fun writeGeneratedEventToFile(event: GeneratedEvent, dataDir: File) {
    if(event.genType in generated2misc.keys) {
        val misc = generated2misc[event.genType]?:return
        val file = File(dataDir, "generated/${misc.name}.csv")
        file.sink(append = true).buffer().use { sink ->
            if(misc.size > 0) {
                repeat(misc.size) { i ->
                    sink.writeUtf8("${event.data[i]}")
                    sink.writeUtf8(",")
                }
            }

            sink.writeUtf8("${event.timestamp}")
            sink.writeUtf8("\n")
        }
    } else {
        Log.w("writeToFile", "strange generated event type")
    }
}

