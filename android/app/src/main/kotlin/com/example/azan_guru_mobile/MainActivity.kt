package com.example.azan_guru_mobile

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.net.Uri

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ATTENTION: This was auto-generated to handle app links.
        val appLinkIntent: Intent = intent
        val appLinkAction: String? = appLinkIntent.action
        val appLinkData: Uri? = appLinkIntent.data
    }
}
