package com.example.timetable_app

import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity : FlutterActivity() {
	private val channelName = "timetable_app/gallery_saver"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
			when (call.method) {
				"saveImage" -> {
					try {
						val bytes = call.argument<ByteArray>("bytes")
						val fileName = call.argument<String>("fileName") ?: "timetable.png"
						val mimeType = call.argument<String>("mimeType") ?: "image/png"

						if (bytes == null) {
							result.error("invalid_args", "Image bytes were null", null)
							return@setMethodCallHandler
						}

						val savedUri = saveImageToGallery(bytes, fileName, mimeType)
						if (savedUri != null) {
							result.success(savedUri.toString())
						} else {
							result.error("save_failed", "Unable to save image to gallery", null)
						}
					} catch (exception: Exception) {
						result.error("save_failed", exception.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun saveImageToGallery(bytes: ByteArray, fileName: String, mimeType: String): android.net.Uri? {
		val resolver = applicationContext.contentResolver
		val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
		} else {
			MediaStore.Images.Media.EXTERNAL_CONTENT_URI
		}

		val values = ContentValues().apply {
			put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
			put(MediaStore.Images.Media.MIME_TYPE, mimeType)
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
				put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Timetable_app")
				put(MediaStore.Images.Media.IS_PENDING, 1)
			}
		}

		val uri = resolver.insert(collection, values) ?: return null

		try {
			resolver.openOutputStream(uri, "w")?.use { outputStream: OutputStream ->
				outputStream.write(bytes)
				outputStream.flush()
			} ?: return null

			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
				values.clear()
				values.put(MediaStore.Images.Media.IS_PENDING, 0)
				resolver.update(uri, values, null, null)
			}

			return uri
		} catch (exception: Exception) {
			resolver.delete(uri, null, null)
			throw exception
		}
	}
}
