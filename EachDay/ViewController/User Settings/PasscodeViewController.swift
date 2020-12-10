//
//  PasscodeViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/9.
//

import UIKit
import SVPinView

class PasscodeViewController: UIViewController {
    weak var delegate: PasscodeViewControllerDelegate?
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var isEditingPasscode = false
    var isDisablingPasscode = false
    var passcode: String?
    var secondPasscode: String?
    var count = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPasscode()
        configurePinView()
    }
    
    func configurePinView() {
        pinView.keyboardType = .phonePad
        pinView.becomeFirstResponderAtIndex = 0
        if isEditingPasscode {
            self.configureEditingView()
        } else if isDisablingPasscode {
            self.configureDisablingView()
        } else {
            configureSetUpView()
        }
    }
    
    func configureSetUpView() {
        pinView.didFinishCallback = { [weak self] pin in
            print("The passcode is \(pin)")
            self?.checkPasscode(pin: pin)
//            UserManager.shared.updatePasscode(userDocID: "Eleanor", passcode: self?.passcode ?? "")
//            self?.showCompleteAlert()
        }
    }
    
    func checkPasscode(pin: String) {
        if count == 1 {
            firstCheck(pin: pin)
        } else if count == 2 {
            secondCheck(pin: pin)
        }
    }
    
    func configureEditingView() {
        if isEditingPasscode {
            titleLabel.text = "Enter Old Passcode"
        }
        pinView.didFinishCallback = { [weak self] pin in
            if pin == self?.passcode {
                self?.count = 1
                self?.titleLabel.text = "Enter New Passcode"
                self?.checkPasscode(pin: pin)
            } else {
                self?.showIncompleteAlert()
            }
        }
    }
    
    func configureDisablingView() {
        if isDisablingPasscode {
            titleLabel.text = "Enter Old Passcode"
        }
        pinView.didFinishCallback = { [weak self] pin in
            if pin == self?.passcode {
                UserManager.shared.updatePasscode(userDocID: "Eleanor", passcode: "")
                self?.delegate?.handlePasscodeSet(hasSet: false)
                self?.showCompleteAlert()
            } else {
                self?.showIncompleteAlert()
            }
        }
    }
    
    func fetchPasscode() {
        UserManager.shared.fetchUser(userID: "Eleanor", completion: { result in
            switch result {
            case .success(let user):
                self.passcode = user[0].passcode
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func createShakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))

        view.layer.add(animation, forKey: "position")
    }
    
    func firstCheck(pin: String) {
        passcode = pin
        count += 1
        titleLabel.text = "Re-enter Passcode"
        pinView.clearPin()
    }
    
    func secondCheck(pin: String) {
        secondPasscode = pin
        self.delegate?.handlePasscodeSet(hasSet: true)
        if passcode == secondPasscode {
            UserManager.shared.updatePasscode(userDocID: "Eleanor", passcode: passcode ?? "")
            showCompleteAlert()
        } else {
            showIncompleteAlert()
        }
    }
    
    func showCompleteAlert() {
        let alert = UIAlertController(title: isDisablingPasscode ? "Passcode disabled." : "Your passcode is set!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showIncompleteAlert() {
        let alert = UIAlertController(title: "Please enter the correct passcode.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.delegate?.getPasscodeState(isEditing: false, isDisabling: false)
            self.pinView.clearPin()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UserSettingViewController {
            if passcode != nil {
                destination.hasPasscode = true
            } else {
                destination.hasPasscode = false
            }
        }
    }
}

protocol PasscodeViewControllerDelegate: AnyObject {
    func handlePasscodeSet(hasSet: Bool)
    func getPasscodeState(isEditing: Bool, isDisabling: Bool)
}
