//
//  User.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/12.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    var uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountTypeIndex"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
 
