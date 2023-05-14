//
//  HomeViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/09.
//

import UIKit
import SnapKit
import FirebaseAuth
import MapKit
import CoreLocation

private let reuseIdentifier = "LocationCell"
private let annotationIndentifier = "DriverAnnotation"

class HomeViewController: UIViewController {

//MARK: - UI Components
    private let mapView = MKMapView()
    // 위치 묻는 역할
    private let locationManager = LocationHandler.shared.locationManager
    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private final let locationInputViewHeight: CGFloat = 200 // - 어디서든 수정 불가
    private var user: User? {
        // 단일 책임 원칙으로 유저에 유저 정보를 넣어서 LocationInputView 자체에서 변경가능하게
        didSet { locationInputView.user = user }
    }
    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        signOut()
        view.backgroundColor = .backgroundColor
        navigationController?.navigationBar.isHidden = true
        setUIandConstraints()
        enableLocationServices()
        fetchUserData()
        fetchDrivers()
    }
    
//MARK: - Firebase API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fatchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers() {
        print("DEBUG: HomeView called - fetchDriver")
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDriver(location: location) { (driver) in //
            guard let coordinate = driver.location?.coordinate else { return } // Driver location (드라이버 좌표 업데이트 시 coordinate도 변경)
            let annotation = DriverAnnotation.init(uid: driver.uid, coordinate: coordinate) // mapView에 driver 마킹
            
            // 드라이버의 정보가 있다면 
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        // 드라이버 위치 갱신
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        print("DEBUG: Driver 위치 갱신")
                        return true
                    } else {
                        return false
                    }
                })
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
            
        }
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: 로그아웃 에러")
        }
    }
    
//MARK: - set UI
    func setUIandConstraints() {
        configureMapView()
        configureLocationActivationView()
        configureTableView()
    }
    
    // MapView
    func configureMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.mapView.delegate = self
    }
    
    // 홈 뷰에 있는 where to Bar
    func configureLocationActivationView() {
        view.addSubview(locationInputActivationView)
        locationInputActivationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(view.frame.width - 64)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        locationInputActivationView.alpha = 0
        locationInputActivationView.delegate = self
        
        // 뷰가 보일 시 애니메이션
        UIView.animate(withDuration: 2) {
            self.locationInputActivationView.alpha = 1
        }
        
    }
    
    // where to Bar를 누르면 나오는 View
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            // tableView 애니메이션
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
            
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
//MARK: - Helper
}

//MARK: - MKMapViewDelegate: Driver 마킹을 여러 개 X -> 단일화
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIndentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
}

//MARK: - 위치 사용 권한 부여
extension HomeViewController {
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: 위치 정보 없을 때 권한 정보 물음")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: 항상 위치정보 권한 사용중")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: 앱을 사용할 때만 위치정보 권한 사용중")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }   
    }
}


//MARK: - LocationInputActivationViewDelegate
extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        locationInputActivationView.alpha = 0 // locationInputView를 띄우며 사라져보이게
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate
extension HomeViewController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        // 뷰 스택 쌓이지않게 삭제 - 중요
        // 천천히 사라지게
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            
        }) { _ in
            // 천천히 다시 나타나게
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.locationInputActivationView.alpha = 1
            })
        }
    }
}

//MARK: - TableView Delegate/DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }

}
