//
//  UIImage + Extension.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/26.
//

import Foundation
import UIKit

extension UIImage {
    func withAlpha(_ a: CGFloat) -> UIImage {
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (_) in
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: a)
        }
    }
}
