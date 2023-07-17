//
//  MenuViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/13.
//

import UIKit
import SnapKit

private let reuseIdentifier = "MenuCell"

class MenuViewController: UIViewController {

//MARK: - Properties
    private let user: User
    
    private lazy var menuHeaderView: MenuHeaderView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = MenuHeaderView(user: user, frame: frame)
        return view
    }()
    
    private let menuTabelView: UITableView = {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        return $0
    }(UITableView())
    
//MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        menuTabelView.delegate = self
        menuTabelView.dataSource = self
        configureTableView()
        setUIandConstraints()
 
    }
    
//MARK: - Helper Functions
    func configureTableView() {
        menuTabelView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        menuTabelView.tableHeaderView = menuHeaderView
    }
    
//MARK: - set UI
    func setUIandConstraints() {
        view.addSubview(menuTabelView)
        
        menuTabelView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

//MARK: - TableView Delegate
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Menu Option"
        
        return cell
    }
}

