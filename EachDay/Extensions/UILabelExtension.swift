//
//  UILabelExtension.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/16.
//

import Foundation
import UIKit

extension UILabel {
    
    func changeLineSpacing(lineSpacing: CGFloat, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19)]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        self.attributedText = attributedString
    }
}
