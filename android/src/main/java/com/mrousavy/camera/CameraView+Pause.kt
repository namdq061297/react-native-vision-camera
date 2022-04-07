package com.mrousavy.camera

import android.annotation.SuppressLint
import android.util.Log

@SuppressLint("RestrictedApi")
suspend fun CameraView.stopCamera() {
  Log.e(CameraView.TAG, "stopCamera")
  cameraProvider?.unbindAll()
}

@SuppressLint("RestrictedApi")
suspend fun CameraView.resumeCamera() {
  Log.e(CameraView.TAG, "resumeCamera")
}
