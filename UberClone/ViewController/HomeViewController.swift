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

class HomeViewController: UIViewController {

//MARK: - UI Components
    private let mapView = MKMapView()
    // 위치 묻는 역할
    private let locationManager = CLLocationManager()
    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private final let locationInputViewHeight: CGFloat = 200 // - 어디서든 수정 불가
    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        signOut()
        view.backgroundColor = .backgroundColor
        navigationController?.navigationBar.isHidden = true
        setUIandConstraints()
        enableLocationServices()
    }
    
//MARK: - Firebase API
    
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
            print("DEBUG : 테이블 뷰 올라오는 중")
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        tableView.backgroundColor = .red
        view.addSubview(tableView)
    }
    
//MARK: - Helper
    
    
    
}

extension HomeViewController: CLLocationManagerDelegate {
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: 위치 정보 없을 때 권한 정보 물음")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: 항상 위치정보 권한 사용중")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: 앱을 사용할 때만 위치정보 권한 사용중")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    // 권한 부여 상태 변경 시
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
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
        // 천천히 사라지게
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
        }) { _ in
            // 천천히 다시 나타나게
            UIView.animate(withDuration: 0.3, animations: {
                self.locationInputActivationView.alpha = 1
            })
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }

}