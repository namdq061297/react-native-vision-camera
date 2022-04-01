//
//  CameraView+Pause.swift
//  VisionCamera
//
//  Created by Nguyen Dat on 01/04/2022.
//  Copyright © 2022 mrousavy. All rights reserved.
//

import Foundation

extension CameraView {
  func stopCamera(promise: Promise) {
    cameraQueue.async {
      withPromise(promise) {
        if self.isRunning {
          self.captureSession.stopRunning()
        }
        return nil
      }
    }
  }

  func resumeCamera(promise: Promise) {
    cameraQueue.async {
      withPromise(promise) {
        if !self.isRunning {
          self.captureSession.startRunning()
        }
        return nil
      }
    }
  }
}
