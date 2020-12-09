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
    var passcode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePinView()
    }
    
    func configurePinView() {
        pinView.keyboardType = .phonePad
        pinView.becomeFirstResponderAtIndex = 0
        pinView.didFinishCallback = { [weak self] pin in
            print("The passcode is \(pin)")
            self?.passcode = pin
            self?.delegate?.handlePasscodeSet(hasSet: true)
//            UserManager.shared.updatePasscode(userDocID: "Eleanor", passcode: self?.passcode ?? "")
            self?.showCompleteAlert()
        }
    }
    
    func showCompleteAlert() {
        let alert = UIAlertController(title: "Your Passcode Is Set!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
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
}
