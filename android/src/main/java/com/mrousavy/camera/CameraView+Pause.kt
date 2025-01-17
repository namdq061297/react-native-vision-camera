package com.mrousavy.camera

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import android.util.Log
import kotlinx.coroutines.launch

@SuppressLint("RestrictedApi")
fun CameraView.stopCamera() {
  Log.e(CameraView.TAG, "stopCamera")
  Handler(Looper.getMainLooper()).post(Runnable {
    cameraProvider?.unbindAll()
  })
}

@SuppressLint("RestrictedApi")
fun CameraView.resumeCamera() {
  Log.e(CameraView.TAG, "resumeCamera")
  Handler(Looper.getMainLooper()).post(Runnable {
    coroutineScope.launch {
      configureSession()
    }
  })
}
