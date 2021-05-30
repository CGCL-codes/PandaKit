package com.example.sensorscollector2.activity

import android.app.Activity
import android.os.Bundle
import android.widget.Toast
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.sensorscollector2.R
import com.example.sensorscollector2.adaptor.ActivityListAdaptor
import com.permissionx.guolindev.PermissionX

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setSupportActionBar(findViewById(R.id.toolbar))

        val mainActivities = findViewById<RecyclerView>(R.id.mainActivityList)
        val layoutManager = LinearLayoutManager(this)
        mainActivities.layoutManager = layoutManager
        val adaptor = ActivityListAdaptor(list)
        mainActivities.adapter = adaptor

        PermissionX.init(this)
            .permissions(android.Manifest.permission.BLUETOOTH_ADMIN, android.Manifest.permission.ACCESS_FINE_LOCATION)
            .request { allGranted, _, deniedList ->
                if (allGranted) {
//                    Toast.makeText(this, "permission granted", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this, "permission denied: $deniedList", Toast.LENGTH_SHORT).show()
                }
            }
    }

    companion object {
        val list = listOf<Pair<String, Activity>>(
            Pair("collector", CollectorActivity()),
            Pair("naive pdr", NaivePdrActivity()),
            Pair("tests", TestEntryActivity())
        )
    }
}