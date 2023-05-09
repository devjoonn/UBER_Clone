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

class HomeViewController: UIViewController {

//MARK: - UI Components
    private let mapView = MKMapView()
    
    
//MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        signOut()
        view.backgroundColor = .backgroundColor
        setUIandConstraints()
    }
    
//MARK: - Firebase API
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: 로그아웃 에러")
        }
    }
    
//MARK: - Helper
    func setUIandConstraints() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
}
