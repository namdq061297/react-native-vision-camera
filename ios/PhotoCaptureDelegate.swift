//
//  PhotoCaptureDelegate.swift
//  mrousavy
//
//  Created by Marc Rousavy on 15.12.20.
//  Copyright © 2020 mrousavy. All rights reserved.
//

import AVFoundation
import UIKit

private var delegatesReferences: [NSObject] = []

// MARK: - PhotoCaptureDelegate

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
  private let promise: Promise

  required init(promise: Promise) {
    self.promise = promise
    super.init()
    delegatesReferences.append(self)
  }

  func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    defer {
      delegatesReferences.removeAll(where: { $0 == self })
    }
    if let error = error as NSError? {
      promise.reject(error: .capture(.unknown(message: error.description)), cause: error)
      return
    }

    let error = ErrorPointer(nilLiteral: ())
    guard let tempFilePath = RCTTempFilePath("jpeg", error)
    else {
      promise.reject(error: .capture(.createTempFileError), cause: error?.pointee)
      return
    }
    let url = URL(string: "file://\(tempFilePath)")!

    guard let data = photo.fileDataRepresentation() else {
      promise.reject(error: .capture(.fileError))
      return
    }

    guard let image = UIImage(data: data) else {
      promise.reject(error: .capture(.fileError))
      return
    }

    let rotateImage = UIImage.rotateCameraImageToProperOrientation(imageSource: image)

    do {
//      try data.write(to: url)
      try rotateImage.data?.write(to: url)

      let width = rotateImage.size.width
      let height = rotateImage.size.height
//      let exif = photo.metadata["{Exif}"] as? [String: Any]
//      let width = exif?["PixelXDimension"]
//      let height = exif?["PixelYDimension"]

      promise.resolve([
        "path": tempFilePath,
        "width": width,
        "height": height,
        "isRawPhoto": photo.isRawPhoto,
        "metadata": photo.metadata,
        "thumbnail": photo.embeddedThumbnailPhotoFormat as Any,
      ])
    } catch {
      promise.reject(error: .capture(.fileError), cause: error as NSError)
    }
  }

  func photoOutput(_: AVCapturePhotoOutput, didFinishCaptureFor _: AVCaptureResolvedPhotoSettings, error: Error?) {
    defer {
      delegatesReferences.removeAll(where: { $0 == self })
    }
    if let error = error as NSError? {
      promise.reject(error: .capture(.unknown(message: error.description)), cause: error)
      return
    }
  }
}
