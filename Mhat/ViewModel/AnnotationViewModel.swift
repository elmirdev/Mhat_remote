//
//  AnnotationViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 19.06.22.
//

import Foundation
import UIKit

struct AnnotationViewModel {
    let user: User
    
//    var borderColor: UIColor {
//        return user.isCurrentUser ? .customBlue : .systemGray7
//    }
    
    var usernameLabel: String {
        return user.isCurrentUser ? "You" : user.username
    }
    
    init(user: User) {
        self.user = user
    }
}
