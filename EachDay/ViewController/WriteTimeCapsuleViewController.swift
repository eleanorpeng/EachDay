//
//  WriteTimeCapsuleViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit

class WriteTimeCapsuleViewController: UIViewController {

    @IBAction func uploadButtonClicked(_ sender: Any) {
    }
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    let helper = Helper()
    @IBAction func sendButtonClicked(_ sender: Any) {
        
    }
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func initialSetUp() {
        let buttonBackground = helper.createCircularButtonBackground(view: view)
        let button = helper.createButton(background: buttonBackground, image: UIImage(named: "back")!)
        NSLayoutConstraint.activate([
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonBackground.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        contentTextView.delegate = self
        contentTextView.text = "Record detail of your day"
        contentTextView.textColor = .lightGray
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension WriteTimeCapsuleViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = "What would you like to send?"
            contentTextView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.textColor == UIColor.lightGray {
            contentTextView.text = nil
            contentTextView.textColor = UIColor.black
        }
    }
}
