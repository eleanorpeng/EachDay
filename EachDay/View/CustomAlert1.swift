//
//  CustomAlertView.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/13.
//

import UIKit
import Lottie

//class CustomAlert: UIView, Modal {
//
////    var backgroundView = UIView()
////    var alertView = UIView()
//    var backgroundView = UIView()
//    var dialogView = UIView()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//    }
//    convenience init(title:String,image:UIImage) {
//        self.init(frame: UIScreen.main.bounds)
//        initialize(title: title, image: image)
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented!")
//    }
//
//    func initialize() {
//        backgroundView.frame = frame
//        backgroundView.backgroundColor = .black
//        backgroundView.alpha = 0.6
//        addSubview(backgroundView)
//
//
//        addSubview(alertView)
//
//        NSLayoutConstraint.activate([
//            alertView.widthAnchor.constraint(equalToConstant: frame.width - 64),
//            alertView.heightAnchor.constraint(equalToConstant: 400)
//        ])
//
//        alertView.clipsToBounds = true
//        alertView.layer.cornerRadius = 6
//        alertView.backgroundColor = .white
//
//        let alertViewWidth = frame.width - 64
//        let titleLabel = UILabel()
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        alertView.addSubview(titleLabel)
//        titleLabel.text = "You Have a New Time Cap!"
//        titleLabel.textAlignment = .center
//
//        NSLayoutConstraint.activate([
//            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: 16)
//        ])
//
//        let animationView: AnimationView?
//        animationView = .init(name: "mailbox")
//        animationView?.contentMode = .scaleAspectFit
//        animationView?.loopMode = .loop
//        animationView?.animationSpeed = 0.5
//        animationView?.translatesAutoresizingMaskIntoConstraints = false
//        alertView.addSubview(animationView!)
//
//        NSLayoutConstraint.activate([
//            animationView!.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 10),
//            animationView!.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: 10),
//            animationView!.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
//        ])
//
//        let button = UIButton()
//        button.setTitle("Open", for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        alertView.addSubview(button)
//
//        NSLayoutConstraint.activate([
//            button.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
//            button.topAnchor.constraint(equalTo: animationView!.bottomAnchor, constant: 20),
//            button.widthAnchor.constraint(equalToConstant: 50)
//        ])
//
//        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
//
//    }
//
//    @objc func didTappedOnBackgroundView() {
//        dismiss(animated: true)
//    }
//
//}

import UIKit

class CustomAlert1: UIView, Modal1 {
    var backgroundView = UIView()
    var dialogView = UIView()
    
    
    convenience init(title:String,image:UIImage) {
        self.init(frame: UIScreen.main.bounds)
        initialize(title: title, image: image)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialize(title:String, image:UIImage){
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)
        
        let dialogViewWidth = frame.width-64
        
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        dialogView.addSubview(titleLabel)
        
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        dialogView.addSubview(separatorLineView)
        
        
        let imageView = UIImageView()
        imageView.frame.origin = CGPoint(x: 8, y: separatorLineView.frame.height + separatorLineView.frame.origin.y + 8)
        imageView.frame.size = CGSize(width: dialogViewWidth - 16 , height: dialogViewWidth - 16)
        imageView.image = image
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        dialogView.addSubview(imageView)
        
        let dialogViewHeight = titleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + imageView.frame.height + 8
        
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 6
        addSubview(dialogView)
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
}
