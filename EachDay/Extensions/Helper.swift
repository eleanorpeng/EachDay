//
//  Helper.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit

class Helper {
    func createCircularButton(view: UIView, image: UIImage) -> UIView {
        let buttonBackground = UIView()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.backgroundColor = UIColor(hexString: "F1F1F1")
        view.addSubview(buttonBackground)
        buttonBackground.addSubview(button)
        
        NSLayoutConstraint.activate([
            buttonBackground.widthAnchor.constraint(equalToConstant: 50),
            buttonBackground.heightAnchor.constraint(equalToConstant: 50),
            button.topAnchor.constraint(equalTo: buttonBackground.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: buttonBackground.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: buttonBackground.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: buttonBackground.bottomAnchor, constant: -10)
        ])
        
        button.setImage(image, for: .normal)
        buttonBackground.clipsToBounds = true
        buttonBackground.layer.cornerRadius = 25
        
        return buttonBackground
    }
    
    func createCircularButtonBackground(view: UIView) -> UIView {
        let buttonBackground = UIView()
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.backgroundColor = UIColor(hexString: "F1F1F1")
        view.addSubview(buttonBackground)
        
        NSLayoutConstraint.activate([
            buttonBackground.widthAnchor.constraint(equalToConstant: 50),
            buttonBackground.heightAnchor.constraint(equalToConstant: 50)
        ])
        buttonBackground.clipsToBounds = true
        buttonBackground.layer.cornerRadius = 25
        
        return buttonBackground
    }
    
    func createButton(background: UIView, image: UIImage) -> UIButton {
        let button = UIButton()
        background.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: background.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -10)
        ])
        button.setImage(image, for: .normal)
        
        return button
    }
}
