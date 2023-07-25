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
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private let type: LocationType
    private let location: CLLocation
    
// MARK: - Life cycles
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
        
        print("DEBUG: Type is \(type.description)")
        print("DEBUG: Location is \(location)")
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

    // 검색 완료
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
        
    }
    
}

//MARK: - TableView
extension AddLocationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuserIdentifier)
        return cell
    }
}

//MARK: - UISearchBarDelegate
extension AddLocationViewController: UISearchBarDelegate {
    // searchBar에서 text가 변경될 때 마다
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//MARK: - MKLocalSearchCompleterDelegate
extension AddLocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        
        print("DEBUG: SearchResult = \(searchResults)")
        
        tableView.reloadData()
    }
}
