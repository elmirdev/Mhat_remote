//
//  ProfileViewModel.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import Foundation
import UIKit

struct ProfileViewModel{
    
    private let user: User
    
    var editProfileAddFriendButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }

        if !user.isFriend && !user.isRequested {
            return "Add Friend"
        }
        
        if user.isFriend && !user.isCurrentUser {
            return "Friend"
        }
        
        if user.isRequested && !user.isFriend && !user.isCurrentUser {
            return "Requested"
        }
        
        return "Loading"
    }
    
    var messageLogoutButtonTitle: String {
        if user.isCurrentUser {
            return "Logout"
        }
        
        if !user.isCurrentUser {
            return "Message"
        }
        
        return "Loading"
    }
    
    var shouldShowMessageButton: Bool {
        return !user.isFriend ? true : false
    }
    
    var messageLogoutButtonColor: UIColor {
        return user.isCurrentUser ? .systemRed : .lightGray
    }
    
    init(user: User) {
        self.user = user
    }
}
