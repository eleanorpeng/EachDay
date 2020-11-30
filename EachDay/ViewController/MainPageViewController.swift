//
//  MainPageViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import UIKit
import FanMenu
import Macaw

class MainPageViewController: UIViewController {
    @IBOutlet weak var fanMenu: FanMenu!
    @IBOutlet weak var maskView: UIView!
    let months = ["Nov", "Nov"]
    let dates = ["24", "25"]
    let menuView = UIView()
    let menuItems = [
        "write",
        "timeCapsule"
    ]
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        createMenuButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fanMenu.updateNode()
    }
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func createButton() {
        let buttonBackground = UIView()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.backgroundColor = UIColor(hexString: "F1F1F1")
        view.addSubview(buttonBackground)
        buttonBackground.addSubview(button)
        
        NSLayoutConstraint.activate([
            buttonBackground.widthAnchor.constraint(equalToConstant: 50),
            buttonBackground.heightAnchor.constraint(equalToConstant: 50),
            buttonBackground.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -16),
            buttonBackground.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            button.topAnchor.constraint(equalTo: buttonBackground.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: buttonBackground.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: buttonBackground.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: buttonBackground.bottomAnchor, constant: -10)
        ])
        
        button.setImage(UIImage(named: "plus"), for: .normal)
        buttonBackground.clipsToBounds = true
        buttonBackground.layer.cornerRadius = 25
    }
    
    func createMenuButton() {
        fanMenu.translatesAutoresizingMaskIntoConstraints = false
        fanMenu.button = FanMenuButton(id: "main", image: UIImage(named: "menu_add")?.resizedImageWith(targetSize: CGSize(width: 30, height: 30)), color: Color.rgba(r: 255, g: 155, b: 113, a: 1))
        fanMenu.items = menuItems.map({ button in
            return FanMenuButton(id: button, image: UIImage(named: "menu_\(button)")?.resizedImageWith(targetSize: CGSize(width: 30, height: 30)), color: Color.rgba(r: 241, g: 241, b: 241, a: 1))
        })
        fanMenu.menuRadius = 90.0
        fanMenu.duration = 0.2
        fanMenu.delay = 0.05
        fanMenu.interval = (Double.pi, 2 * Double.pi)
        fanMenu.onItemDidClick = { button in
            if button.id == "write" {
                self.performSegue(withIdentifier: "ShowWriteJournalSegue", sender: self)
            } else if button.id == "timeCapsule" {
                self.performSegue(withIdentifier: "ShowTimeCapsuleSegue", sender: self)
            }
            print("ItemDidClick: \(button.id)")
        }

        fanMenu.onItemWillClick = { button in
            self.maskView.isHidden = self.fanMenu.isOpen
            print("ItemWillClick: \(button.id)")
        }
        fanMenu.backgroundColor = .clear
        fanMenu.menuBackground = Color.rgba(r: 247, g: 174, b: 0, a: 0.5)
    }
}

extension MainPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 110
        } else {
            return 200
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return configureGreetingCell(indexPath: indexPath)
        } else {
            return configureJournalCell(indexPath: indexPath)
        }
    }
    
    func configureGreetingCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainPageGreetingsTableViewCell.identifier, for: indexPath)
        guard let greetingCell = cell as? MainPageGreetingsTableViewCell else { return cell }
        greetingCell.layoutCell(name: "Eleanor", profilePic: UIImage(named: "user")!)
        return greetingCell
    }
    
    func configureJournalCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JournalTableViewCell.identifier, for: indexPath)
        guard let journalCell = cell as? JournalTableViewCell else { return cell }
        if indexPath.row == 0 {
            journalCell.layoutCell(month: months[indexPath.section-1], date: dates[indexPath.section-1], title: "Yay", content: "Yup")
        } else {
            journalCell.dateLabel.isHidden = true
            journalCell.monthLabel.isHidden = true
        }
        return journalCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
