//
//  SettingsViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/18.
//

import UIKit
import SnapKit

private let reuseIdentifier = "LocationCell"

protocol SettingsViewControllerDelegate: class {
    func updateUser(_ controller: SettingsViewController)
}

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}

class SettingsViewController: UITableViewController {
//MARK: - properties
    var user: User
    private let locationManager = LocationHandler.shared.locationManager
    weak var delegate: SettingsViewControllerDelegate?
    var userInfoUpdated = false
    
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
    // 셀의 addressLabel에 주소값을 보여줄 때
    func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeaderView
        tableView.tableFooterView = UIView()
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
    // Setting 화면에서 나갈 시
    @objc func handleDismissal() {
         // API를 요청해 값이 변경되었다면
        if userInfoUpdated {
            // homeLocation, workLocation이 저장되어있는 user 객체 -> ContainerView 넣음
            delegate?.updateUser(self)
        }
        
        self.dismiss(animated: true)
    }

}

//MARK: - UITableView Delegate
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
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
        
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager?.location else { return }
        let controller = AddLocationViewController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav,animated: true)
    }
}

//MARK: - AddLocationViewControllerDelegate
extension SettingsViewController: AddLocationViewControllerDelegate {
    func updateLocation(locationString: String, type: LocationType) {
        // DB에 주소 선택 값 key value 저장
        PassengerService.shared.saveLocation(locationString: locationString, type: type) { (error, ref) in
            self.dismiss(animated: true)
            // API가 불려 성공적으로 DB에 저장되었을 시 userInfoUpdate 변경
            self.userInfoUpdated = true
            
            // 저장한 값을 user에 입력
            switch type {
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            
            self.tableView.reloadData()
        }
    }
}
