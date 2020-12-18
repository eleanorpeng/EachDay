//
//  SignInViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/16.
//

import UIKit
import Lottie
import KeychainAccess

class SignInViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var signInButton: UIButton!
    @IBAction func signInButtonClicked(_ sender: Any) {
        configureSignInStatus(status: true)
        uploadUserData()
        performSegue(withIdentifier: "ShowMainFromSignIn", sender: self)
    }
    let keychain = Keychain()
    var calendarColors: [String]?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnimation()
        setUpButton()
        configureSignInStatus(status: false)
        UserDefaults.standard.setValue(false, forKey: EPUserDefaults.enableBiometrics.rawValue)
        calendarColors = [
            "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00"
        ]
//        UserDefaults.standard.setValue(calendarColors, forKey: "calendarColors")
        keychain["passcode"] = nil
    }
    
    func setUpButton() {
        signInButton.clipsToBounds = true
        signInButton.layer.cornerRadius = 10
    }
    
    func createAnimation() {
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1
        animationView.play()
    }
    
    func configureSignInStatus(status: Bool) {
        UserDefaults.standard.setValue(status, forKey: EPUserDefaults.hasSignedIn.rawValue)
        
    }
    
    func uploadUserData() {
        //Get name from Apple ID
        let user = User(name: "Eleanor",
                        id: "IAMACTUALLYFAKE",
                        email: "eleanorpeng31@gmail.com",
                        passcode: "",
                        journalTags: ["Time Capsule", "Reflection"],
                        trackTimeCategories: ["Eat", "Sleep", "Music", "Commute", "TV", "Read", "Workout", "Work"],
                        image: "", colors: calendarColors!)
        UserDefaults.standard.setValue(user.id, forKey: EPUserDefaults.userId.rawValue)
        UserManager.shared.uploadUserData(user: user, completion: { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        })
    }

}
