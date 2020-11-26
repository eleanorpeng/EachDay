//
//  MainPageGreetingsTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import UIKit

class MainPageGreetingsTableViewCell: UITableViewCell {

    static let identifier = "MainPageGreetingsTableViewCell"
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var greetingLabel2: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func layoutCell(name: String, profilePic: UIImage) {
        greetingLabel.text = "Hi, \(name)"
        greetingLabel2.text = "How's Your Day?"
        profileButton.setImage(profilePic, for: .normal)
        profileButton.tintColor = .black
    }
}
