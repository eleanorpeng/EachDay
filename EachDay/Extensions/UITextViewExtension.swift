//
//  UITextViewExtension.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/14.
//

import Foundation
import UIKit

extension UITextView {
    func changeLineSpacing(text: String, lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        self.attributedText = attributedString

    }
    
    func setUpTitle(text: String, lineSpacing: CGFloat = 3) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        self.attributedText = attributedString
    }
    
    func setUpContentText(text: String, lineSpacing: CGFloat = 3) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        self.attributedText = attributedString
    }
    
}

