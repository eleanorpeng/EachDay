//
//  SelectionViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class SelectionViewController: UIViewController {

    @IBOutlet weak var writeJournalButtonView: UIView!
    @IBOutlet weak var timeCapsuleButtonView: UIView!
    
    @IBAction func writeJournalButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteJournalFromSelection", sender: self)
    }
    
    @IBAction func timeCapsuleButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTimeCapsuleFromSelection", sender: self)
    }
    
    @IBAction func writeJournalTextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteJournalFromSelection", sender: self)
    }
    
    @IBAction func timeCapsuleTextButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTimeCapsuleFromSelection", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        writeJournalButtonView.isUserInteractionEnabled = true
        timeCapsuleButtonView.isUserInteractionEnabled = true
        addTapGestures()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WriteJournalViewController {
            destination.isWritingSummary = false
        }
    }
    
    func addTapGestures() {
        let writeJournalTap = UITapGestureRecognizer(target: self, action: #selector(handleWriteJournalTapped(_:)))
        writeJournalButtonView.addGestureRecognizer(writeJournalTap)
        let timeCapsuleTap = UITapGestureRecognizer(target: self, action: #selector(handleTimeCapsuleTapped(_:)))
        timeCapsuleButtonView.addGestureRecognizer(timeCapsuleTap)
    }
    
    @objc func handleWriteJournalTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ShowWriteJournalFromSelection", sender: self)
    }
    
    @objc func handleTimeCapsuleTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ShowTimeCapsuleFromSelection", sender: self)
    }
    
}
