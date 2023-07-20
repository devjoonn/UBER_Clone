//
//  AddLocationViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/21.
//

import UIKit
import MapKit
import SnapKit

private let reuserIdentifier = "Cell"

class AddLocationViewController: UITableViewController {
// MARK: - Properties
    private let searchBar = UISearchBar()
    
// MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
    }

//MARK: - Helper Functions
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuserIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        tableView.addShadow()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }

}

extension AddLocationViewController: UISearchBarDelegate {
    
}
