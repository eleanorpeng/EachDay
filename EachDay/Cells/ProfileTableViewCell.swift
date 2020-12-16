//
//  ProfileTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit
import YPImagePicker
import Kingfisher

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    weak var delegate: ProfileTableViewCellDelegate?
    var isEditingProfile = false
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBAction func editProfileButtonClicked(_ sender: Any) {
        isEditingProfile = !isEditingProfile
        configureEditProfileButton()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func layoutCell(profileImage: String?, name: String) {
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        if profileImage != nil {
            userProfileImageView.kf.setImage(with: URL(string: profileImage!))
        } else {
            userProfileImageView.image = UIImage(named: "user")
        }
        userNameTextField.isUserInteractionEnabled = false
        userNameTextField.borderStyle = .none
        userNameTextField.text = name
        userNameTextField.delegate = self
     
    }
    
    func configureEditProfileButton() {
        if isEditingProfile {
            editProfileButton.setImage(nil, for: .normal)
            editProfileButton.setTitle("Done", for: .normal)
            editProfileButton.setTitleColor(.black, for: .normal)
            userNameTextField.isUserInteractionEnabled = true
            userNameTextField.borderStyle = .roundedRect
            createImageMaskView()
        } else {
            editProfileButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            editProfileButton.setTitle(nil, for: .normal)
            userNameTextField.borderStyle = .none
            userNameTextField.isUserInteractionEnabled = false
            removeMaskView()
        }
    }
    
    func createImageMaskView() {
        let maskView = UIView()
        let maskViewLabel = UILabel()
        maskViewLabel.text = "Edit"
        maskViewLabel.textColor = .white
        maskView.addSubview(maskViewLabel)
        maskViewLabel.translatesAutoresizingMaskIntoConstraints = false
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        maskView.translatesAutoresizingMaskIntoConstraints = false
        maskView.clipsToBounds = true
        maskView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.addSubview(maskView)
        NSLayoutConstraint.activate([
            maskView.leadingAnchor.constraint(equalTo: userProfileImageView.leadingAnchor),
            maskView.trailingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor),
            maskView.topAnchor.constraint(equalTo: userProfileImageView.topAnchor),
            maskView.bottomAnchor.constraint(equalTo: userProfileImageView.bottomAnchor),
            maskViewLabel.centerXAnchor.constraint(equalTo: maskView.centerXAnchor),
            maskViewLabel.centerYAnchor.constraint(equalTo: maskView.centerYAnchor)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfileImage(tapGestureRecognizer:)))
        maskView.isUserInteractionEnabled = true
        maskView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func editProfileImage(tapGestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.handleEditImage()
    }
    
    func removeMaskView() {
        userProfileImageView.subviews.forEach({
            $0.removeFromSuperview()
        })
    }
}

extension ProfileTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        userNameTextField.text = textField.text
        UserManager.shared.updateUserName(userDocID: "Eleanor", name: userNameTextField.text ?? "")
        isEditingProfile = !isEditingProfile
        configureEditProfileButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol ProfileTableViewCellDelegate: AnyObject {
    func handleEditImage()
}
