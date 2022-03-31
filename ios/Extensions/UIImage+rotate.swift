//
//  UIImage+rotate.swift
//  VisionCamera
//
//  Created by Nguyen Dat on 31/03/2022.
//  Copyright © 2022 mrousavy. All rights reserved.
//

extension UIImage {
  var maxLength: CGFloat { return 1080 }
  var width: CGFloat { return size.width }
  var height: CGFloat { return size.height }
  var aspectRatio: CGFloat { return width == 0 ? 0 : height / width }
  var byte: Int { return pngData()!.count }
  var data: Data? { return pngData() }

  func resize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage!
  }

  func fixOrientation() -> UIImage {
    if imageOrientation == .up {
      return self
    }
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
      UIGraphicsEndImageContext()
      return normalizedImage
    } else {
      return self
    }
  }

  static func rotateCameraImageToProperOrientation(imageSource: UIImage, maxResolution: CGFloat = CGFloat.greatestFiniteMagnitude) -> UIImage {
    let imgRef = imageSource.cgImage

    let width = CGFloat(imgRef!.width)
    let height = CGFloat(imgRef!.height)

    var bounds = CGRect(x: 0, y: 0, width: width, height: height)

    var scaleRatio: CGFloat = 1
    if width > maxResolution || height > maxResolution {
      scaleRatio = min(maxResolution / bounds.size.width, maxResolution / bounds.size.height)
      bounds.size.height *= scaleRatio
      bounds.size.width *= scaleRatio
    }

    var transform = CGAffineTransform.identity
    let orient = imageSource.imageOrientation
    let imageSize = CGSize(width: imgRef!.width, height: imgRef!.height)

    switch imageSource.imageOrientation {
    case .up:
      transform = CGAffineTransform.identity

    case .upMirrored:
      transform = CGAffineTransform(translationX: imageSize.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)

    case .down:
      transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
      transform = transform.rotated(by: CGFloat.pi)

    case .downMirrored:
      transform = CGAffineTransform(translationX: 0, y: imageSize.height)
      transform = transform.scaledBy(x: 1, y: -1)

    case .left:
//                let storedHeight = bounds.size.height
//                bounds.size.height = bounds.size.width
//                bounds.size.width = storedHeight
//                transform = CGAffineTransform(translationX: 0, y: imageSize.width)
//                transform = transform.rotated(by: 3.0 * CGFloat.pi / 2.0)

      let storedHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = storedHeight
      transform = CGAffineTransform(scaleX: -1, y: 1)
      transform = transform.rotated(by: CGFloat.pi / 2.0)

    case .leftMirrored:
      let storedHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = storedHeight
      transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
      transform = transform.scaledBy(x: -1, y: 1)
      transform = transform.rotated(by: 3.0 * CGFloat.pi / 2.0)

    case .right:
      let storedHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = storedHeight
      transform = CGAffineTransform(translationX: imageSize.height, y: 0)
      transform = transform.rotated(by: CGFloat.pi / 2.0)

    case .rightMirrored:
      let storedHeight = bounds.size.height
      bounds.size.height = bounds.size.width
      bounds.size.width = storedHeight
      transform = CGAffineTransform(scaleX: -1, y: 1)
      transform = transform.rotated(by: CGFloat.pi / 2.0)

    @unknown default:
      fatalError()
    }

    UIGraphicsBeginImageContext(bounds.size)
    let context = UIGraphicsGetCurrentContext()

    if orient == .right || orient == .left {
      context!.scaleBy(x: -scaleRatio, y: scaleRatio)
      context!.translateBy(x: -height, y: 0)
    } else {
      context!.scaleBy(x: scaleRatio, y: -scaleRatio)
      context!.translateBy(x: 0, y: -height)
    }

    context!.concatenate(transform)
    context!.draw(imgRef!, in: CGRect(x: 0, y: 0, width: width, height: height))

    let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return imageCopy!
  }
}
