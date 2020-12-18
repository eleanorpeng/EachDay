//
//  SlideUpView.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/17.
//

import Foundation
import UIKit

class SlideUpView: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: SlideUpViewDelegate?
    let colors = ["FFE066", "ffd54f", "ffa270", "f7ae00", "ffcdd2", "e1bee7",
                  "d4e157", "81c784", "70C1B3", "62A87C", "6ec6ff",
                  "3A6EA5", "798086", "85756E", "2E2F2F"]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorPickerCollectionViewCell.self), for: indexPath)
        guard let colorCell = cell as? ColorPickerCollectionViewCell else { return cell }
        colorCell.layoutCell(color: UIColor(hexString: colors[indexPath.row]))
        colorCell.colorButton.addTarget(self, action: #selector(colorButtonClicked(_:)), for: .touchUpInside)
        return colorCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        self.delegate?.changeCalendarColor(color: UIColor(hexString: colors[indexPath.row]))
//        dismissSlideUp()
//    }
    
    @objc func colorButtonClicked(_ sender: UIButton) {
        self.delegate?.changeCalendarColor(color: sender.backgroundColor!)
        dismissSlideUp()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
    
    private let customView: UIView = {
        let customView = UIView()
        customView.backgroundColor = .white
        customView.layer.masksToBounds = true
        customView.layer.cornerRadius = 12
        return customView
    }()
    
    private var slideUp: UICollectionView?
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: 60, height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        
        return collectionView
    }()
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 247, g: 174, b: 0)
        return button
    }()
    
    private var myTargetView: UIView?
    
    override init() {
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: ColorPickerCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "ColorPickerCollectionViewCell")
    }
    
    func showSlideView(on viewController: UIViewController) {
        guard let targetView = viewController.view else { return }
        myTargetView = targetView
        backgroundView.frame = targetView.bounds
        collectionView.frame = CGRect(x: 0, y: 65, width: targetView.frame.width, height: 330)
        customView.frame = CGRect(x: 0, y: targetView.frame.height, width: targetView.frame.width, height: 400)
        createTitle()
        collectionView.backgroundColor = .white
        targetView.addSubview(backgroundView)
        targetView.addSubview(customView)
        customView.addSubview(collectionView)
        collectionView.reloadData()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSlideUp))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        showSlideUpAnimation()
    }
    
    func setUpCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: customView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: customView.bottomAnchor)
        ])
    }
    
    func createTitle() {
        let titleLabel = UILabel()
        guard let targetView = myTargetView else { return }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Select Color"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        customView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: customView.topAnchor, constant: 16)
        ])
//        return titleLabel
    }
    
    func showSlideUpAnimation() {
        guard let targetView = myTargetView else { return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 0.6
            self.customView.frame = CGRect(x: 0, y: targetView.frame.height - self.customView.frame.height, width: targetView.frame.width, height: self.customView.frame.height)
        }, completion: nil)
    }
    
    @objc func dismissSlideUp() {
        guard let targetView = myTargetView else { return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut,animations: {
            self.customView.frame = CGRect(x: 0, y: targetView.frame.height, width: targetView.frame.width, height: self.customView.frame.height)
            self.backgroundView.alpha = 0
        }, completion: nil)
    }
}

protocol SlideUpViewDelegate: AnyObject {
    func changeCalendarColor(color: UIColor)
}
