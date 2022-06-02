package com.rosseapp.time_tracker

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder
import android.widget.Toast


class OnReceiver : BroadcastReceiver() {


    override fun onReceive(context: Context, intent: Intent) {

        Toast.makeText(context, "Received intent!", Toast.LENGTH_SHORT)
        if (intent.action == Intent.ACTION_SCREEN_ON) {
            context.startActivity(Intent(context, MainActivity::class.java))
            Toast.makeText(context, "screen ON", Toast.LENGTH_LONG).show()
        }
    }
}
