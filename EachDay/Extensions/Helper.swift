//
//  Helper.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit

class Helper {
    
    func createCircularBackground(view: UIView, color: UIColor, width: CGFloat, height: CGFloat) -> UIView {
        let buttonBackground = UIView()
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.backgroundColor = color
        view.addSubview(buttonBackground)
        
        NSLayoutConstraint.activate([
            buttonBackground.widthAnchor.constraint(equalToConstant: width),
            buttonBackground.heightAnchor.constraint(equalToConstant: height)
        ])
        buttonBackground.clipsToBounds = true
        buttonBackground.layer.cornerRadius = width / 2
        
        return buttonBackground
    }
    
    func createButton(background: UIView, image: UIImage, padding: CGFloat) -> UIButton {
        let button = UIButton()
        background.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: background.topAnchor, constant: padding),
            button.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: padding),
            button.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -padding),
            button.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -padding)
        ])
        button.setImage(image, for: .normal)
        
        return button
    }
    
}
