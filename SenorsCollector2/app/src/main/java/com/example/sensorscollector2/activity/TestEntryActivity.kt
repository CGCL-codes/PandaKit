package com.example.sensorscollector2.activity

import android.app.Activity
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.sensorscollector2.activity.tests.TestOrientationActivity
import com.example.sensorscollector2.activity.tests.TestRealtimeAccelerationActivity
import com.example.sensorscollector2.activity.tests.TestStepDetectorActivity
import com.example.sensorscollector2.adaptor.ActivityListAdaptor
import com.example.sensorscollector2.databinding.ActivityTestEntryBinding

class TestEntryActivity : AppCompatActivity() {

    private lateinit var binding : ActivityTestEntryBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTestEntryBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val layoutManager =  LinearLayoutManager(this)
        binding.testEntriesView.layoutManager = layoutManager
        val adaptor = ActivityListAdaptor(tests)
        binding.testEntriesView.adapter = adaptor
    }

    companion object {
        val tests = arrayListOf<Pair<String, Activity>>(
            Pair("orientation", TestOrientationActivity()),
            Pair("linear acceleration", TestRealtimeAccelerationActivity()),
            Pair("step detector", TestStepDetectorActivity())
        )
    }
}