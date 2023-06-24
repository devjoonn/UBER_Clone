//
//  Trip.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/24.
//

import CoreLocation

struct Trip {
    let pickupCoordinates: CLLocationCoordinate2D
    let destinationCoordinates: CLLocationCoordinate2D
    let passengerUid: String
    var driverUid: String?
    
}

