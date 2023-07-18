//
//  SettingsViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/18.
//

import UIKit
import SnapKit

private let reuseIdentifier = "LocationCell"

class SettingsViewController: UITableViewController {
//MARK: - properties
    private let user: User
    
    private lazy var infoHeaderView: UserInfoHeaderView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let view = UserInfoHeaderView(user: user, frame: frame)
        return view
    }()
    
    
//MARK: - Life cycles
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        
    }
    
//MARK: - Helper Function
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeaderView
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .backgroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "baseline_clear_white")?.withRenderingMode(.alwaysOriginal),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(handleDismissal))
    }
    
//MARK: - Selector
    @objc func handleDismissal() {
        self.dismiss(animated: true)
    }

}
