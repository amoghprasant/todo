package com.example.flutter_application_1

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class MainActivity: FlutterActivity() {
    private val CHANNEL_ID = "your_channel_id" // Define your channel ID here
    private val CHANNEL_NAME = "your_channel_name"
    private val CHANNEL_DESCRIPTION = "your_channel_description"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel() // Create the notification channel
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = CHANNEL_NAME
            val descriptionText = CHANNEL_DESCRIPTION
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.flutter_application_1/notification").setMethodCallHandler { call, result ->
            if (call.method == "showNotification") {
                showNotification(call.argument("title") ?: "", call.argument("body") ?: "")
                result.success("Notification shown")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showNotification(title: String, body: String) {
        val builder = NotificationCompat.Builder(this, CHANNEL_ID) // Use the channel ID here
            .setSmallIcon(R.drawable.ic_launcher) // Replace with your icon
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        val notificationManager = NotificationManagerCompat.from(this)
        notificationManager.notify(0, builder.build()) // 0 is the notification ID
    }
}
