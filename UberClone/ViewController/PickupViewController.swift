//
//  PickupViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/26.
//

import UIKit
import MapKit
import SnapKit

protocol PickupViewControllerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupViewController: UIViewController {

//MARK: - Properties
    let trip: Trip
    weak var delegate: PickupViewControllerDelegate?
    
    private lazy var circularProgressView: CircularProgressView = {
        let cp = CircularProgressView(frame: .zero)
        
        cp.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.width.height.equalTo(268)
            $0.centerX.centerY.equalToSuperview()
        }
        mapView.layer.cornerRadius = 268 / 2
        
        return cp
    }()
    
    private let mapView: MKMapView = {
        $0.layer.cornerRadius = 270 / 2
        return $0
    }(MKMapView())
    
    private let cancelButton: UIButton = {
        $0.setImage(UIImage(named: "baseline_clear_white"), for: .normal)
        $0.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return $0
    }(UIButton())
    
    private let pickupLabel: UILabel = {
        $0.text = "Would you like to pickup this passenger?"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
        return $0
    }(UILabel())
    
    private let acceptTripButton: UIButton = {
        $0.backgroundColor = .white
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        $0.setTitle("ACCEPT TRIP", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
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
        configureMapView()
    }
    
//MARK: - Helper Functions
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
    }
    
//MARK: - Configure UI
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelButton)
        view.addSubview(circularProgressView)
        view.addSubview(pickupLabel)
        view.addSubview(acceptTripButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(16)
        }
        circularProgressView.snp.makeConstraints { make in
            make.width.height.equalTo(360)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.centerX.equalToSuperview()
            
        }
        pickupLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circularProgressView.snp.bottom).inset(-50)
        }
        acceptTripButton.snp.makeConstraints { make in
            make.top.equalTo(pickupLabel.snp.bottom).inset(-16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
    }
    
//MARK: - Selector
    @objc func handleDismissal() {
        dismiss(animated: true)
    }

    @objc func handleAcceptTrip() {
        DriverService.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
}
