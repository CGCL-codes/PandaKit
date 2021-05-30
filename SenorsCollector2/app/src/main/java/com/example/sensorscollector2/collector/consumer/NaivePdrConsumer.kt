package com.example.sensorscollector2.collector.consumer

import com.example.sensorscollector2.Utils.GeneratedType
import com.example.sensorscollector2.collector.DataEvent
import com.example.sensorscollector2.model.GeneratedEvent
import com.example.sensorscollector2.model.TYPE_GENERATED_EVENT
import com.example.sensorscollector2.model.TYPE_SENSOR_EVENT
import com.example.sensorscollector2.pdr.heading.IOrientationDetector
import com.example.sensorscollector2.pdr.step.IStepDetector
import com.example.sensorscollector2.pdr.stride.IStrideStrategy
import kotlin.math.cos
import kotlin.math.sin

class NaivePdrConsumer(
    val stepDetector: IStepDetector,
    val orientationDetector: IOrientationDetector,
    val strideLengthStrategy: IStrideStrategy,
    val followingConsumers: List<ISensorEventConsumer>,
    private var x: Double = 0.0,
    private var y: Double = 0.0
): ISensorEventConsumer {
    override fun consume(event: DataEvent) {
        when(event.type) {
            TYPE_SENSOR_EVENT -> {

                consumeGeneratedEvent(stepDetector.updateWithDataEvent(event))
                consumeGeneratedEvent(orientationDetector.updateWithDataEvent(event))

                if(stepDetector.isStepDetected()) {
                    // update
                    val strideLength = strideLengthStrategy.getStrideLength()
                    val orientation = orientationDetector.getOrientation()
                    if(orientation.isEmpty()) return
                    // remap
                    val angle = Math.PI/2 - orientation[0]
                    val deltaX = strideLength * cos(angle)
                    val deltaY = strideLength * sin(angle)
                    x += deltaX
                    y += deltaY
                    // consume this movement
                    val genEvent = DataEvent(
                        TYPE_GENERATED_EVENT,
                        GeneratedEvent(
                            GeneratedType.Gen_Trajectory,
                            floatArrayOf(x.toFloat(), y.toFloat()),
                            stepDetector.lastDetectedTimestamp()
                        )
                    )
                    consumeGeneratedEvent(genEvent)
                }
            }
        }
    }

    private fun consumeGeneratedEvent(event: DataEvent?) {
        if(event == null) return
        for(consumer in followingConsumers)
            consumer.consume(event)
    }

    companion object {
        val generatedList = listOf(
            GeneratedType.Gen_Step_Detector,
            GeneratedType.Gen_Rotation_Angles,
            GeneratedType.Gen_Trajectory
        )
    }

}