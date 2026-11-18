package com.tam.tam_customer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tam/location_diagnostics")
            .setMethodCallHandler { call, result ->
                if (call.method != "isVpnActive") {
                    result.notImplemented()
                } else {
                    val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                    val capabilities = manager.getNetworkCapabilities(manager.activeNetwork)
                    result.success(capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true)
                }
            }
    }
}
