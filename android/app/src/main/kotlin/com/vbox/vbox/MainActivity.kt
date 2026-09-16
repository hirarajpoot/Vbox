package com.vbox.vbox

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.TrafficStats
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.Socket
import java.net.URL

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> Thread {
                        val stats = readTunStats()
                        Handler(Looper.getMainLooper()).post { result.success(stats) }
                    }.start()
                    "publicIp" -> Thread {
                        try {
                            val ip = fetchPublicIp()
                            Handler(Looper.getMainLooper()).post { result.success(ip) }
                        } catch (error: Exception) {
                            Handler(Looper.getMainLooper()).post {
                                result.error("ip", error.message, null)
                            }
                        }
                    }.start()
                    else -> result.notImplemented()
                }
            }
    }

    private fun fetchPublicIp(): String {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        var last: Exception = Exception("VPN network not found")
        repeat(5) {
            val vpn = findVpnNetwork(cm)
            try {
                return readIpPlain(vpn, "1.1.1.1", "/cdn-cgi/trace")
            } catch (error: Exception) {
                last = error
            }
            try {
                return readIpPlain(vpn, "1.0.0.1", "/cdn-cgi/trace")
            } catch (error: Exception) {
                last = error
            }
            val urls = listOf(
                "https://1.1.1.1/cdn-cgi/trace",
                "https://1.0.0.1/cdn-cgi/trace",
                "http://1.1.1.1/cdn-cgi/trace",
                "https://api.ipify.org",
                "http://api.ipify.org",
            )
            for (raw in urls) {
                try {
                    return readIpHttp(vpn, raw)
                } catch (error: Exception) {
                    last = error
                }
            }
            Thread.sleep(900)
        }
        throw last
    }

    private fun findVpnNetwork(cm: ConnectivityManager): android.net.Network? {
        for (network in cm.allNetworks) {
            val caps = cm.getNetworkCapabilities(network)
            if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true) {
                return network
            }
            val name = cm.getLinkProperties(network)?.interfaceName ?: continue
            if (name.startsWith("tun") || name.startsWith("ppp")) return network
        }
        val active = cm.activeNetwork ?: return null
        val caps = cm.getNetworkCapabilities(active)
        return if (caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true) active else null
    }

    private fun readIpPlain(network: android.net.Network?, host: String, path: String): String {
        val socket = Socket()
        try {
            network?.bindSocket(socket)
            socket.connect(InetSocketAddress(host, 80), 6000)
            socket.soTimeout = 6000
            val out = socket.getOutputStream()
            out.write(
                "GET $path HTTP/1.0\r\nHost: $host\r\nConnection: close\r\n\r\n"
                    .toByteArray(Charsets.US_ASCII),
            )
            out.flush()
            val body = socket.getInputStream().bufferedReader().readText()
            return parsePublicIp(body) ?: throw Exception("no ip in $host")
        } finally {
            try {
                socket.close()
            } catch (_: Exception) {
            }
        }
    }

    private fun readIpHttp(network: android.net.Network?, raw: String): String {
        val url = URL(raw)
        val conn = (if (network != null) network.openConnection(url) else url.openConnection())
            as HttpURLConnection
        conn.connectTimeout = 6000
        conn.readTimeout = 6000
        conn.instanceFollowRedirects = true
        conn.useCaches = false
        conn.setRequestProperty("User-Agent", "VBox")
        try {
            val code = conn.responseCode
            val stream = if (code in 200..299) conn.inputStream else conn.errorStream
            val body = stream?.bufferedReader()?.use { it.readText() } ?: ""
            return parsePublicIp(body) ?: throw Exception("HTTP $code")
        } finally {
            conn.disconnect()
        }
    }

    private fun parsePublicIp(raw: String): String? {
        Regex("""(?:^|[\s;])ip=([0-9]{1,3}(?:\.[0-9]{1,3}){3})""", RegexOption.IGNORE_CASE)
            .find(raw)
            ?.groupValues
            ?.get(1)
            ?.let { return it }
        val body = raw.substringAfter("\r\n\r\n", raw.substringAfter("\n\n", raw)).trim()
        return Regex("""\b((?:\d{1,3}\.){3}\d{1,3})\b""").find(body)?.groupValues?.get(1)
    }

    private fun readTunStats(): Map<String, Long> {
        val net = File("/sys/class/net")
        val names = net.list() ?: emptyArray()
        var tunRx = 0L
        var tunTx = 0L
        var phyRx = 0L
        var phyTx = 0L
        for (name in names) {
            val rx = readLong(File("/sys/class/net/$name/statistics/rx_bytes"))
            val tx = readLong(File("/sys/class/net/$name/statistics/tx_bytes"))
            if (name.startsWith("tun") || name.startsWith("ppp")) {
                tunRx += rx
                tunTx += tx
            } else if (!name.startsWith("lo") && !name.startsWith("dummy")) {
                phyRx += rx
                phyTx += tx
            }
        }
        val useTun = tunRx > 0 || tunTx > 0
        if (useTun) return mapOf("rx" to tunRx, "tx" to tunTx)
        if (phyRx > 0 || phyTx > 0) return mapOf("rx" to phyRx, "tx" to phyTx)
        val rx = TrafficStats.getTotalRxBytes()
        val tx = TrafficStats.getTotalTxBytes()
        return mapOf(
            "rx" to if (rx < 0) 0L else rx,
            "tx" to if (tx < 0) 0L else tx,
        )
    }

    private fun readLong(file: File): Long {
        return try {
            file.readText().trim().toLong()
        } catch (_: Exception) {
            0L
        }
    }

    companion object {
        private const val CHANNEL = "vbox/tun_stats"
    }
}
