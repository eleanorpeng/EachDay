//
//  SignInViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/16.
//

import UIKit
import Lottie
import KeychainAccess
import AuthenticationServices

class SignInViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var signInButton: UIButton!
    @IBAction func signInButtonClicked(_ sender: Any) {
        configureSignInStatus(status: true)
        uploadUserData()
        
    }
    let keychain = Keychain()
    var calendarColors: [String]?
    var userID: String?
    var email: String?
    var name: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnimation()
        setUpButton()
        signInButton.isHidden = true
        configureSignInStatus(status: false)
        UserDefaults.standard.setValue(false, forKey: EPUserDefaults.enableBiometrics.rawValue)
        calendarColors = [
            "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00", "F7AE00"
        ]
//        UserDefaults.standard.setValue(calendarColors, forKey: "calendarColors")
        keychain["passcode"] = nil
        addSignInButton()
    }
    
    func addSignInButton() {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleUserSignIn), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 80),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 45),
            button.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    @objc func handleUserSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
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
        //Get name from Apple ID, will change user info based on Apple ID info
        var user = User(name: name ?? "",
                        id: userID ?? "",
                        email: email ?? "",
                        passcode: "",
                        journalTags: ["Time Capsule", "Reflection"],
                        trackTimeCategories: ["Eat", "Sleep", "Music", "Commute", "TV", "Read", "Workout", "Work"],
                        image: "",
                        colors: calendarColors!)
        UserManager.shared.uploadUserData(user: &user, completion: { result in
            switch result {
            case .success(let message):
                print(message)
                self.performSegue(withIdentifier: "ShowMainFromSignIn", sender: self)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            userID = credential.user
            UserDefaults.standard.setValue(credential.email, forKey: "userEmail")
            UserDefaults.standard.setValue(credential.fullName?.givenName, forKey: "userName")
            UserDefaults.standard.setValue(userID, forKey: EPUserDefaults.userId.rawValue)
        }
        guard !UserDefaults.standard.bool(forKey: EPUserDefaults.hasSignedIn.rawValue) else { return }
        uploadUserData()
        UserDefaults.standard.setValue(true, forKey: EPUserDefaults.hasSignedIn.rawValue)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


