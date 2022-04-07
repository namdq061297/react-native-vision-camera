package com.mrousavy.camera

import android.annotation.SuppressLint
import android.util.Log

@SuppressLint("RestrictedApi")
fun CameraView.stopCamera() {
  Log.e(CameraView.TAG, "stopCamera")
  cameraProvider?.unbindAll()
}

@SuppressLint("RestrictedApi")
fun CameraView.resumeCamera() {
  Log.e(CameraView.TAG, "resumeCamera")
}
