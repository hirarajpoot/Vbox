package com.vbox.vbox

import android.net.TrafficStats
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.Proxy
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
        var last: Exception = Exception("tunnel IP failed")
        try {
            return readIpViaHttpProxy(10809)
        } catch (error: Exception) {
            last = error
        }
        for (port in intArrayOf(10808, 1080)) {
            try {
                return readIpViaSocks(port)
            } catch (error: Exception) {
                last = error
            }
        }
        throw last
    }

    private fun readIpViaHttpProxy(port: Int): String {
        val proxy = Proxy(Proxy.Type.HTTP, InetSocketAddress("127.0.0.1", port))
        var last: Exception = Exception("http proxy empty")
        val urls = listOf(
            "https://api.ipify.org",
            "http://api.ipify.org",
            "https://ifconfig.me/ip",
        )
        for (raw in urls) {
            val conn = URL(raw).openConnection(proxy) as HttpURLConnection
            conn.connectTimeout = 8000
            conn.readTimeout = 8000
            conn.instanceFollowRedirects = true
            conn.useCaches = false
            conn.setRequestProperty("User-Agent", "VBox")
            try {
                val code = conn.responseCode
                val stream = if (code in 200..299) conn.inputStream else conn.errorStream
                val body = stream?.bufferedReader()?.use { it.readText() } ?: ""
                return parsePublicIp(body) ?: throw Exception("HTTP $code")
            } catch (error: Exception) {
                last = error
            } finally {
                conn.disconnect()
            }
        }
        throw last
    }

    private fun readIpViaSocks(port: Int): String {
        val socket = Socket()
        try {
            socket.bind(InetSocketAddress("127.0.0.1", 0))
            socket.connect(InetSocketAddress("127.0.0.1", port), 4000)
            socket.soTimeout = 5000
            val out = socket.getOutputStream()
            val inp = socket.getInputStream()
            out.write(byteArrayOf(0x05, 0x01, 0x00))
            out.flush()
            val greet = ByteArray(2)
            readFully(inp, greet)
            if (greet[0] != 0x05.toByte() || greet[1] != 0x00.toByte()) {
                throw Exception("socks auth $port")
            }
            out.write(byteArrayOf(0x05, 0x01, 0x00, 0x01, 1, 1, 1, 1, 0x00, 0x50))
            out.flush()
            val head = ByteArray(4)
            readFully(inp, head)
            if (head[1] != 0x00.toByte()) {
                throw Exception("socks connect ${head[1].toInt() and 0xff}")
            }
            skipSocksBind(inp, head[3].toInt() and 0xff)
            out.write(
                "GET /cdn-cgi/trace HTTP/1.0\r\nHost: 1.1.1.1\r\nConnection: close\r\n\r\n"
                    .toByteArray(Charsets.US_ASCII),
            )
            out.flush()
            val body = inp.bufferedReader().readText()
            return parsePublicIp(body) ?: throw Exception("socks empty $port")
        } finally {
            try {
                socket.close()
            } catch (_: Exception) {
            }
        }
    }

    private fun skipSocksBind(inp: InputStream, atyp: Int) {
        val extra = when (atyp) {
            0x01 -> 6
            0x04 -> 18
            0x03 -> {
                val len = ByteArray(1)
                readFully(inp, len)
                (len[0].toInt() and 0xff) + 2
            }
            else -> 0
        }
        if (extra > 0) readFully(inp, ByteArray(extra))
    }

    private fun readFully(inp: InputStream, buf: ByteArray) {
        var off = 0
        while (off < buf.size) {
            val n = inp.read(buf, off, buf.size - off)
            if (n < 0)             throw Exception("socks eof")
            off += n
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
