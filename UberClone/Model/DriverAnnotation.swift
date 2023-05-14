//
//  DriverAnnotation.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/14.
//

import UIKit
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D // 좌표속성 - dynamic을 붙여야 마킹이 동적으로 위치 변경
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }

    // Driver 위치 변경 시 맵 뷰에 좌표 마킹 업데이트
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
}

