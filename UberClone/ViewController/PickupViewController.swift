//
//  PickupViewController.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/26.
//

import UIKit
import MapKit

class PickupViewController: UIViewController {

//MARK: - Properties
    private let mapView = MKMapView()
    
    let trip: Trip
    
//MARK: - Life cycles
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    


}
