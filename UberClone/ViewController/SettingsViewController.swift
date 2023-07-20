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

//MARK: - UITableView Delegate
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = {
            $0.backgroundColor = .backgroundColor 
            return $0
        }(UIView())
        
        let title: UILabel = {
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textColor = .white
            $0.text = "Favorites"
            return $0
        }(UILabel())
        
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        cell.titleLabel.text = "Home"
        
        return cell
    }
}
