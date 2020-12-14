//
//  JournalTagsCollectionViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/14.
//

import UIKit

class JournalTagsCollectionViewCell: UICollectionViewCell {
    static let identifier = "JournalTagsCollectionViewCell"
    @IBOutlet weak var tagLabel: PaddingableUILabel!
    
    func layoutCell(tag: String) {
        tagLabel.text = tag
    }
}
