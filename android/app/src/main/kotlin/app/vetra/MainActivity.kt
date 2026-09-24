package app.vetra

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    // Opens this app's notification settings, for when Android will no longer show the
    // permission dialog (the user denied it before).
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.vetra/settings").setMethodCallHandler { call, result ->
            if (call.method != "openNotificationSettings") return@setMethodCallHandler result.notImplemented()
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
            }
            startActivity(intent)
            result.success(null)
        }
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
