//
//  Trip.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/24.
//

import CoreLocation

struct Trip {
    var pickupCoordinates: CLLocationCoordinate2D
    let destinationCoordinates: CLLocationCoordinate2D
    let passengerUid: String
    var driverUid: String?
    var state: TripState!
    
    init(passengerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passengerUid
         
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            
        }
    }
}

enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
}
