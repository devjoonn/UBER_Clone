//
//  MenuViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/11.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuViewController: UITableViewController {

//MARK: - Properties
    
    
    
    
//MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

 
    }
//MARK: - Helper Functions
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
}
