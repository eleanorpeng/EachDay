//
//  SelectionViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class SelectionViewController: UIViewController {

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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WriteJournalViewController {
            destination.isWritingSummary = false
        }
    }
}
