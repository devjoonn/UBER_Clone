//
//  PickupViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/26.
//

import UIKit
import MapKit
import SnapKit

class PickupViewController: UIViewController {

//MARK: - Properties
    private let mapView = MKMapView()
    let trip: Trip
    
    private let cancelButton: UIButton = {
        $0.setImage(UIImage(named: "baseline_clear_white"), for: .normal)
        $0.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return $0
    }(UIButton())
    
//MARK: - Life cycles
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
        print(trip.passengerUid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

    }
    
//MARK: - Configure UI
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(16)
        }
    }
    
//MARK: - Selector
    @objc func handleDismissal() {
        dismiss(animated: true)
    }

}
