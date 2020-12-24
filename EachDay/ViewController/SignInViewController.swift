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
import CryptoKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    
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
    fileprivate var currentNonce: String?
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
        currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce ?? "")
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
                        colors: calendarColors!,
                        routineTime: nil)
        UserManager.shared.uploadUserData(user: user, completion: { result in
            switch result {
            case .success(let message):
                print(message)
                self.performSegue(withIdentifier: "ShowMainFromSignIn", sender: self)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    //    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    //        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
    //            userID = credential.user
    //            UserDefaults.standard.setValue(credential.email, forKey: "userEmail")
    //            UserDefaults.standard.setValue(credential.fullName?.givenName, forKey: "userName")
    //            UserDefaults.standard.setValue(userID, forKey: EPUserDefaults.userId.rawValue)
    //        }
    //        guard !UserDefaults.standard.bool(forKey: EPUserDefaults.hasSignedIn.rawValue) else { return }
    //        uploadUserData()
    //        UserDefaults.standard.setValue(true, forKey: EPUserDefaults.hasSignedIn.rawValue)
    //    }
    
    //    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    //        print(error)
    //    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

@available(iOS 13.0, *)
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            //        UserDefaults.standard.setValue(appleIDCredential.user, forKey: EPUserDefaults.userId.rawValue)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
//                guard error != nil else { return }
//                guard let user = authResult?.user else { return }
//                self.email = user.email ?? ""
//                self.name = user.displayName ?? ""
//                guard let uid = Auth.auth().currentUser?.uid else { return }
//                self.userID = uid
//                UserDefaults.standard.setValue(self.userID, forKey: EPUserDefaults.userId.rawValue)
//                self.uploadUserData()
                if let error = error {
                    print(error)
                }
                guard let user = authResult?.user else { return }
                self.email = user.email ?? ""
                self.name = user.displayName ?? ""
                guard let uid = Auth.auth().currentUser?.uid else { return }
                self.userID = uid
                print("User ID: \(self.userID)")
                UserDefaults.standard.setValue(self.userID, forKey: EPUserDefaults.userId.rawValue)
                guard self.userID != nil else { return }
                self.uploadUserData()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
