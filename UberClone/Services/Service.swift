//
//  Service.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/12.
//

import FirebaseDatabase
import FirebaseAuth
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service {
    
    static let shared = Service()
    
    
    func fatchUserData(uid: String, completion: @escaping(User) -> Void) {
        // 현재 유저정보 - 데이터베이스에서 가져옴 / 한 번만 실행
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let user = User(uid: uid,dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchDriver(location: CLLocation, completion: @escaping(User) -> Void) {
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        // 현재 드라이버 정보 - 계속 관찰
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geoFire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                self.fatchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func uploadTrip() {
        
    }
}
