package com.example.flutter_texture_example

import android.graphics.Color
import android.graphics.SurfaceTexture
import android.view.Surface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

class MainActivity : FlutterActivity() {
    private val channel = "flutter_example_texture"
    private lateinit var registry: TextureRegistry.SurfaceTextureEntry
    private lateinit var surfaceTexture: SurfaceTexture
    private lateinit var surface: Surface

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registry = flutterEngine.renderer.createSurfaceTexture()
        surfaceTexture = registry.surfaceTexture()
        val metrics = context.resources.displayMetrics
        val width = metrics.widthPixels
        val height = metrics.heightPixels
        surfaceTexture.setDefaultBufferSize(width, height)
        surface = Surface(surfaceTexture)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "createTexture" -> {
                    val canvas = surface.lockCanvas(null)
                    canvas.drawColor(Color.RED)
                    surface.unlockCanvasAndPost(canvas)
                    result.success(registry.id())
                }

                else -> {
                    result.notImplemented()
                }
            }

        }
    }
}
