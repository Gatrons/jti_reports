package com.example.jti_reports

import android.os.Bundle
import androidx.preference.PreferenceManager
import io.flutter.embedding.android.FlutterActivity
import org.osmdroid.config.Configuration

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Konfigurasi global osmdroid
        val ctx = applicationContext
        Configuration.getInstance().load(
            ctx,
            PreferenceManager.getDefaultSharedPreferences(ctx)
        )
        // UserAgent wajib di-set (pakai applicationId project-mu)
        Configuration.getInstance().userAgentValue = BuildConfig.APPLICATION_ID
    }
}
