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

protocol AddLocationViewControllerDelegate: class {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationViewController: UITableViewController {
// MARK: - Properties
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet { tableView.reloadData() }
    }
    private let type: LocationType
    private let location: CLLocation
    
    weak var delegate: AddLocationViewControllerDelegate?
    
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
        let result = searchResults[indexPath.row]
        
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = title + " " + subtitle
        // DB 저장 값에서 대한민국 제거하고 저장
        let trimLocationString = locationString.replacingOccurrences(of: " 대한민국", with: "")
        delegate?.updateLocation(locationString: trimLocationString, type: type)
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
    // completion 결과를 Result에 담음
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }
}
