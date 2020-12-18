//
//  LoadingView.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/16.
//

import Foundation
import UIKit
import Lottie

class LoadingView {
    private let backgroundview: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let loadingView: AnimationView = {
        var loading = AnimationView()
        loading = .init(name: "loading")
        loading.alpha = 0
        loading.backgroundColor = .clear
        loading.contentMode = .scaleAspectFit
        loading.loopMode = .loop
        loading.animationSpeed = 1.5
        loading.play()
        return loading
    }()
    
    private var myTargetView: UIView?
    
    func startLoading(on viewController: UIViewController) {
        guard let targetView = viewController.view else { return }
        myTargetView = targetView
        loadingView.frame = targetView.frame
        loadingView.center = targetView.center
        backgroundview.frame = targetView.bounds
        
        targetView.addSubview(backgroundview)
        targetView.addSubview(loadingView)
        
        UIView.animate(withDuration: 0.15, animations: {
            self.backgroundview.alpha = 0.6
        }, completion: { done in
            UIView.animate(withDuration: 0.15, animations: {
                self.loadingView.alpha = 1
            })
        })
//        UIView.animate(withDuration: 0.15, animations: {
//            self.loadingView.alpha = 1
//        }, completion: nil)
    }
    
    func dismissLoading() {
        guard let targetView = myTargetView else { return }
        UIView.animate(withDuration: 0.25, animations: {
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundview.alpha = 0
            }, completion: { done in
                self.loadingView.removeFromSuperview()
                self.backgroundview.removeFromSuperview()
            })
        })
    }
    
    func startLoadingWithoutBackground(on viewController: UIViewController) {
        guard let targetView = viewController.view else { return }
        myTargetView = targetView
        loadingView.frame = targetView.frame
        loadingView.center = targetView.center
        backgroundview.frame = targetView.bounds
        
        targetView.addSubview(loadingView)
        
        UIView.animate(withDuration: 0.15, animations: {
            self.loadingView.alpha = 1
        }, completion: nil)
    }
    
    func dismissLoadingWithoutBackground() {
        guard let targetView = myTargetView else { return }
        UIView.animate(withDuration: 0.25, animations: {
            UIView.animate(withDuration: 0.25, animations: {
                self.loadingView.removeFromSuperview()
            }, completion: nil)
        })
    }
}
