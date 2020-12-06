//
//  DetailJournalContentViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/4.
//

import UIKit
import PKHUD

class DetailJournalContentViewController: UIViewController {

    @IBOutlet weak var titleLabelToImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var journalImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagSeparator: UIView!
    @IBOutlet weak var tagLabel: PaddingableUILabel!
    var journalData: Journal?
    var journalVM: JournalViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journalVM = JournalViewModel(journal: journalData!)
        print(journalData)
        initialSetUp()
    }
    
    func initialSetUp() {
//        titleLabelToDateConstraint.isActive = false
        HUD.show(.progress)
        dateLabel.text = journalVM?.formattedDate
        titleLabel.text = journalVM?.title
        contentTextView.text = journalVM?.content
        displayImage()
        layoutTags()
    }
    
    func displayImage() {
        guard journalVM?.image != "" else {
            titleLabelToImageConstraint.constant = -260
            journalImageView.isHidden = true
            HUD.hide()
            return
        }
        guard let urlString = journalVM?.image,
              let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.journalImageView.image = image
                HUD.hide()
            }
        })
        task.resume()
    }
    
    func layoutTags() {
        guard (journalVM?.tags.count)! > 0 else {
            tagLabel.isHidden = true
            tagSeparator.isHidden = true
            return
        }
        tagLabel.text = journalVM?.tags[0]
        tagLabel.clipsToBounds = true
        guard (journalVM?.tags.count)! > 1 else { return }
        var xAnchor: CGFloat = 16
        let journalTags = journalVM?.tags
        var previousTag = tagLabel
        for num in 0..<journalTags!.count-1 {
            let journalTagLabel = PaddingableUILabel()
            journalTagLabel.translatesAutoresizingMaskIntoConstraints = false
            journalTagLabel.backgroundColor = .lightGray
            journalTagLabel.text = journalTags?[num+1]
            journalTagLabel.clipsToBounds = true
            journalTagLabel.cornerRadius = 8
            journalTagLabel.paddingLeft = 8
            journalTagLabel.paddingRight = 8
            journalTagLabel.paddingTop = 8
            journalTagLabel.paddingBottom = 8
            print("XAnchor \(xAnchor)")
            setJournalTagConstraints(previousTag: previousTag!, currentTag: journalTagLabel, xAnchor: &xAnchor)
            previousTag = journalTagLabel
        }
    }
    
    func setJournalTagConstraints(previousTag: PaddingableUILabel, currentTag: PaddingableUILabel, xAnchor: inout CGFloat) {
        currentTag.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentTag)
        NSLayoutConstraint.activate([
            currentTag.leadingAnchor.constraint(equalTo: previousTag.trailingAnchor, constant: xAnchor),
            currentTag.topAnchor.constraint(equalTo: tagSeparator.bottomAnchor, constant: 16),
            currentTag.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
}
