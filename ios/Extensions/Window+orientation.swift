//
//  Window+orientation.swift
//  VisionCamera
//
//  Created by Nguyen Dat on 01/04/2022.
//  Copyright © 2022 mrousavy. All rights reserved.
//

import Foundation

extension UIWindow {
  static var isLandscape: Bool {
    if #available(iOS 13.0, *) {
      return UIApplication.shared.windows
        .first?
        .windowScene?
        .interfaceOrientation
        .isLandscape ?? false
    } else {
      return UIApplication.shared.statusBarOrientation.isLandscape
    }
  }
}
