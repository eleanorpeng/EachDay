//
//  JournalDetailTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class JournalDetailTableViewCell: UITableViewCell {

    static let identifier = "JournalDetailTableViewCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var journalTitleLabel: UILabel!
    @IBOutlet weak var journalContentLabel: UILabel!
    @IBOutlet weak var timeCapsuleIndicator: UIImageView!
    @IBOutlet weak var journalContentTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    var tags: [String]?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    func layoutCell(date: String, day: String, title: String, content: String, tags: [String]) {
        dateLabel.text = date
        dayLabel.text = day
        journalTitleLabel.text = title
        journalContentLabel.text = content
        journalContentLabel.isHidden = true
        journalContentTextView.text = content
        timeCapsuleIndicator.isHidden = true
        self.tags = tags
        
    }
    
    func displayTimeCapsuleIndicator() {
        timeCapsuleIndicator.isHidden = false
    }

}

extension JournalDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10
        
        return tags?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JournalTagsCollectionViewCell.identifier, for: indexPath)
        guard let tagCell = cell as? JournalTagsCollectionViewCell else { return cell }
        tagCell.layoutCell(tag: tags?[indexPath.row] ?? "")
//        tagCell.layoutCell(tag: "Read")
        return tagCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 20)
    }
    
    
}
