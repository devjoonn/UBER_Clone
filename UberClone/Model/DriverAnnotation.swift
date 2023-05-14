//
//  DriverAnnotation.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/14.
//

import UIKit
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D // 좌표속성
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }

    
    
}

