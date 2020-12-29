//
//  PasscodeViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/9.
//

import UIKit
import SVPinView
import KeychainAccess

class PasscodeViewController: UIViewController, UserSettingViewControllerDelegate {
    
    weak var delegate: PasscodeViewControllerDelegate?
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var isInitial = true
    let biometricAuth = BiometricAuthentication()
    let keychain = Keychain()
    var isEditingPasscode = false
    var isDisablingPasscode = false
    var passcode: String?
    var secondPasscode: String?
    var count = 1
    var enableBiometricsAuth = UserDefaults.standard.bool(forKey: EPUserDefaults.enableBiometrics.rawValue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    func initialSetUp() {
        if isInitial && keychain["passcode"] != nil {
            configureIntialView()
        } else if isInitial && keychain["passcode"] == nil {
            performSegue(withIdentifier: "ShowMainSegue", sender: self)
        } else {
            configurePinView()
        }
    }

    //Initial View
    func getBiometricsAuthState(enable: Bool) {
        enableBiometricsAuth = enable
    }
    
    func configureBiometrics() {
        biometricAuth.authenticateUser { [weak self] message in
            if let message = message {
                return
            } else {
                self?.performSegue(withIdentifier: "ShowMainSegue", sender: self)
            }
        }
    }
    
    func configureIntialView() {
        if enableBiometricsAuth {
            configureBiometrics()
        }
        titleLabel.text = "Enter Passcode"
        pinView.becomeFirstResponderAtIndex = 0
        pinView.keyboardType = .phonePad
        pinView.didFinishCallback = { [weak self] pin in
            if pin == self?.keychain["passcode"] {
                self?.performSegue(withIdentifier: "ShowMainSegue", sender: self)
            } else {
                self?.createShakeAnimation()
                self?.subtitleLabel.text = "Incorrect passcode. Please re-enter passcode."
                self?.pinView.clearPin()
            }
        }
    }
    
    //Views from user settings
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
            self?.checkPasscode(pin: pin)
        }
    }
    
    func checkPasscode(pin: String) {
        print("in check passcode")
        if count == 1 {
            print("in first")
            firstCheck(pin: pin)
        } else if count == 2 {
            print("in second")
            secondCheck(pin: pin)
        }
    }
    
    func configureEditingView() {
        if isEditingPasscode {
            titleLabel.text = "Enter Old Passcode"
            subtitleLabel.text = "Please enter old passcode."
        }
        pinView.didFinishCallback = { [weak self] pin in
            if pin == self?.keychain["passcode"] {
                self?.editPasscode()
                self?.pinView.clearPin()
            } else {
                self?.showIncompleteAlert()
            }
        }
    }
    
    func configureDisablingView() {
        if isDisablingPasscode {
            titleLabel.text = "Enter Old Passcode"
            subtitleLabel.text = "Please enter old passcode."
        }
        pinView.didFinishCallback = { [weak self] pin in
            if pin == self?.keychain["passcode"] {
                UserManager.shared.updatePasscode(passcode: "")
                self?.delegate?.handlePasscodeSet(hasSet: false)
                self?.keychain["passcode"] = nil
                UserDefaults.standard.setValue(false, forKey: EPUserDefaults.enableBiometrics.rawValue)
                print("In passcode: \(UserDefaults.standard.bool(forKey: EPUserDefaults.enableBiometrics.rawValue))")
                self?.showCompleteAlert()
            } else {
                self?.showIncompleteAlert()
            }
        }
    }
    
    func fetchPasscode() {
        UserManager.shared.fetchUser(completion: { result in
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
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 5, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 5, y: view.center.y))

        view.layer.add(animation, forKey: "position")
    }
    
    func editPasscode() {
        titleLabel.text = "Enter New Passcode"
        subtitleLabel.text = "Please enter new passcode."
        pinView.didFinishCallback = { [weak self] pin in
            self?.passcode = pin
            self?.keychain["passcode"] = pin
            self?.count = 1
        }
        pinView.clearPin()
        configureSetUpView()
    }
    
    
    func firstCheck(pin: String) {
        passcode = pin
        keychain["passcode"] = passcode
        count += 1
        titleLabel.text = "Re-enter Passcode"
        subtitleLabel.text = "Please re-enter your passcode."
        pinView.clearPin()
    }
    
    func secondCheck(pin: String) {
        secondPasscode = pin
        self.delegate?.handlePasscodeSet(hasSet: true)
        if passcode == secondPasscode {
            UserManager.shared.updatePasscode(passcode: passcode ?? "")
            showCompleteAlert()
        } else {
            showIncompleteAlert()
        }
    }
   
    func showCompleteAlert() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showIncompleteAlert() {
        subtitleLabel.text = "Please enter the correct passcode."
        createShakeAnimation()
        self.delegate?.getPasscodeState(isEditing: false, isDisabling: false)
        pinView.clearPin()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UserSettingViewController {
            //changed from if passcode to keychain
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
