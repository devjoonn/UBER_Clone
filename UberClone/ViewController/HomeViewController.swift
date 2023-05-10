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

class HomeViewController: UIViewController {

//MARK: - UI Components
    private let mapView = MKMapView()
    // 위치 묻는 역할
    private let locationManager = CLLocationManager()
    private let locationInputActivationView = LocationInputActivationView()
    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        signOut()
        view.backgroundColor = .backgroundColor
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
        
        view.addSubview(locationInputActivationView)
        locationInputActivationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(view.frame.width - 64)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        locationInputActivationView.alpha = 0
        locationInputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.locationInputActivationView.alpha = 1
        }
        
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
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

extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        print("LocationInputActivationView Delegate - ")
    }
    
     
}
