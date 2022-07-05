//
//  User.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 18.06.22.
//

import Foundation
import Firebase
import CoreLocation

struct User {
    let uid: String
    let fullname: String
    let username: String
    let profileImageUrl: String
    let phoneNumber: String
    var isFriend = false
    var isRequested = false
    var location: CLLocationCoordinate2D?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(dictionary: [String: Any] = ["": ""]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
    }
}
