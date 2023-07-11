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
let REF_TRIPS = DB_REF.child("trips")

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
    
    // 현재 위치 & 선택 장소 위치 Firebase에 저장
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) { // escaping -> updateChildValues 의 클로저 값 = (Error?, DatabaseReference)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    // driver 시 현재 유저 위치 Firbase에 저장
    func observeTrips(completion: @escaping(Trip) -> Void) {
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    // rider가 매칭 cancel 시 trip 삭제
    func observeTripCancelled(trip: Trip, completion: @escaping () -> Void) {
        REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
            completion()
        }
            
    }
    
    // PickupView에서 accept한 경우
    func acceptTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let value = ["driverUid": uid,
                     "state": TripState.accepted.rawValue] as [String : Any]
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(value, withCompletionBlock: completion)
    }
    
    // 변경된 유저의 TripState 상태를 업데이트
    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    // trip Cancel 취소
    func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    // Driver의 위치 실시간 공유
    func updateDriverLocaton(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let geoFire  = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geoFire.setLocation(location, forKey: uid)
    }
    
    // Trip 매칭의 State로 DB 데이터 변경
    func updateTripState(trip: Trip, state: TripState, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
    }
}
