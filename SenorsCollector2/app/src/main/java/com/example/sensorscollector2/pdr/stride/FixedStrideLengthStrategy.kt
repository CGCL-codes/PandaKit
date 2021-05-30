package com.example.sensorscollector2.pdr.stride

class FixedStrideLengthStrategy(val length: Float): IStrideStrategy {
    override fun getStrideLength(): Float {
        return length
    }
}