//
//  UIButtonExtension.swift
//  EachDay
//
//  Created by Eleanor Peng on 2021/1/7.
//

import UIKit

extension UIButton {
    func createRoundCorners(corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
    }
}
