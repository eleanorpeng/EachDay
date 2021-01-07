//
//  UIImageExtension.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit

extension UIImage {
    func resizedImageWith(targetSize: CGSize) -> UIImage {

        let imageSize = self.size
        let newWidth  = targetSize.width  / self.size.width
        let newHeight = targetSize.height / self.size.height
        var newSize: CGSize

        if newWidth > newHeight {
            newSize = CGSize(width: imageSize.width * newHeight, height: imageSize.height * newHeight)
        } else {
            newSize = CGSize(width: imageSize.width * newWidth, height: imageSize.height * newWidth)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)

        self.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
