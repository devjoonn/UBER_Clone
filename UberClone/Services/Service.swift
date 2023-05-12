//
//  Service.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/12.
//

import FirebaseDatabase
import FirebaseAuth

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid
    
    func fatchUserData() {
        
        // 현재 유저정보
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let fullName = dictionary["fullname"] as? String else { return }
            print("DEBUG : fullname is \(String(describing: fullName))")
            
        }
        
        
    }
}
