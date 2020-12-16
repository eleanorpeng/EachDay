//
//  SignInViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/16.
//

import UIKit
import Lottie

class SignInViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var signInButton: UIButton!
    @IBAction func signInButtonClicked(_ sender: Any) {
        configureSignInStatus(status: true)
        uploadUserData()
        performSegue(withIdentifier: "ShowMainFromSignIn", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnimation()
        setUpButton()
        configureSignInStatus(status: false)
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
                        image: "")
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
