package app.vetra

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val alertChannel = NotificationChannel(
                "vetra_clinical_alerts",
                "Pashu Sathi Clinical & Outbreak Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Emergency notifications for disease outbreaks, appointment status, and critical alerts."
                enableLights(true)
                enableVibration(true)
            }

            val generalChannel = NotificationChannel(
                "vetra_general",
                "Pashu Sathi General Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "General system updates, preventive care tips, and reminders."
            }

            notificationManager.createNotificationChannel(alertChannel)
            notificationManager.createNotificationChannel(generalChannel)
        }
    }
}
