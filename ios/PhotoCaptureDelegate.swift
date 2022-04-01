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
  private let options: NSDictionary
  private let previewFrame: CGRect

  required init(promise: Promise, options: NSDictionary, previewFrame: CGRect) {
    self.promise = promise
    self.options = options
    self.previewFrame = previewFrame
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

//    let rotateImage = UIImage.rotateCameraImageToProperOrientation(imageSource: image)
    var rotateImage = image
    var previewSize: CGSize
    if UIWindow.isLandscape {
      previewSize = CGSize(width: previewFrame.size.width, height: previewFrame.size.height)
    } else {
      previewSize = CGSize(width: previewFrame.size.height, height: previewFrame.size.width)
    }
    let cropRect = CGRect(x: 0, y: 0, width: rotateImage.width, height: rotateImage.height)
    let croppedSize = AVMakeRect(aspectRatio: previewSize, insideRect: cropRect)
    let takenCGImage = rotateImage.cgImage
    let cropCGImage = takenCGImage?.cropping(to: croppedSize)
    guard let cropCGImage = cropCGImage else {
      promise.reject(error: .capture(.fileError))
      return
    }
    ReactLogger.log(level: .info, message: "Before rotate 1------)")
    ReactLogger.log(level: .info, message: "rotateImage.width = \(rotateImage.size.width) - rotateImage.height = \(rotateImage.size.height)")
    rotateImage = UIImage(cgImage: cropCGImage, scale: rotateImage.scale, orientation: rotateImage.imageOrientation)
    ReactLogger.log(level: .info, message: "After rotate 1------)")
    ReactLogger.log(level: .info, message: "rotateImage.width = \(rotateImage.size.width) - rotateImage.height = \(rotateImage.size.height)")
    if let customWidth = options["width"] as? NSNumber {
      var width = CGFloat(truncating: customWidth)
      width /= UIScreen.main.scale
      let scaleRatio = width / CGFloat(rotateImage.size.width)
      ReactLogger.log(level: .info, message: "scaleRatio = \(scaleRatio)")
      let size = CGSize(width: width, height: CGFloat(roundf(Float(rotateImage.size.height * scaleRatio))))
      UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
      rotateImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      guard let newImage = newImage else {
        promise.reject(error: .capture(.fileError))
        return
      }
      ReactLogger.log(level: .info, message: "Before rotate 2------)")
      ReactLogger.log(level: .info, message: "rotateImage.width = \(rotateImage.size.width) - rotateImage.height = \(rotateImage.size.height)")
      rotateImage = UIImage(cgImage: newImage.cgImage!, scale: 1.0, orientation: newImage.imageOrientation)
      ReactLogger.log(level: .info, message: "After rotate 2------)")
      ReactLogger.log(level: .info, message: "rotateImage.width = \(rotateImage.size.width) - rotateImage.height = \(rotateImage.size.height)")
    }

    do {
      let usePng = options["usePng"] as? Bool ?? false
      if usePng {
        try rotateImage.compressPngData?.write(to: url)
      } else {
        try rotateImage.compressJpegData()?.write(to: url)
      }
//      try data.write(to: url)

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
