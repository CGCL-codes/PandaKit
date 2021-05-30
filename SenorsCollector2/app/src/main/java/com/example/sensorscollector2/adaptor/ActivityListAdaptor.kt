package com.example.sensorscollector2.adaptor

import android.app.Activity
import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.recyclerview.widget.RecyclerView
import com.example.sensorscollector2.R


class ActivityListAdaptor(private val activityList : List<Pair<String, Activity>>)
    : RecyclerView.Adapter<ActivityListAdaptor.ViewHolder>()
{
    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val startButton : Button = view.findViewById(R.id.startButton)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.activity_button_item, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val activity = activityList[position]
        holder.startButton.text = activity.first
        holder.startButton.setOnClickListener { view ->
            if(view != null) {
                val intent = Intent(view.context, activity.second.javaClass)
                view.context.startActivity(intent)
            }
        }
    }

    override fun getItemCount() = activityList.size
}