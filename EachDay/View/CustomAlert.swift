//
//  CustomAlert.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/13.
//

import Foundation
import UIKit
import Lottie

class CustomAlert {
    weak var delegate: CustomAlertDelegate?
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()
    
    private var myTargetView: UIView?
    
    func showAlert(on viewController: UIViewController) {
        guard let targetView = viewController.view else { return }
        myTargetView = targetView
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40, y: -300, width: targetView.frame.size.width - 80, height: 300)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: alertView.frame.width, height: 80))
        titleLabel.text = "You Have a Time Cap!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        
        let myAnimationView: AnimationView?
        myAnimationView = .init(name: "mailbox")
        guard let animationView = myAnimationView else { return }
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        animationView.frame = CGRect(x: 0, y: alertView.frame.height - 250, width: alertView.frame.width, height: 250)
        alertView.addSubview(animationView)
        
        let button = UIButton(frame: CGRect(x: 0,
                                            y: alertView.frame.size.height - 50,
                                            width: alertView.frame.width,
                                            height: 50))
        button.setTitle("Open", for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        button.backgroundColor = UIColor(r: 247, g: 174, b: 0)
        button.setTitleColor(.white, for: .normal)
        alertView.addSubview(button)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alertView.center = targetView.center
                })
            }
        })
    }
    
    @objc func dismissAlert() {
        guard let targetView = myTargetView else { return }
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 40, y: targetView.frame.height, width: targetView.frame.size.width - 80, height: 300)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundView.alpha = 0
                }, completion: { done in
                    self.alertView.removeFromSuperview()
                    self.backgroundView.removeFromSuperview()
                    self.delegate?.dismissAlert()
                })
            }
            
        })
    }
}

protocol CustomAlertDelegate: AnyObject {
    func dismissAlert()
}
