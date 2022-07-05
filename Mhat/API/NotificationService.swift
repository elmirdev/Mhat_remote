//
//  NotificationService.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import Foundation
import Firebase

class NotificationService {
    
    static let shared  = NotificationService()
    
    func uploadNotification(uid: String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_NOTIFICATIONS.document(uid).collection("notifications").document(currentUid).setData(["senderUid": currentUid]) { _ in
            COLLECTION_NOTIFICATIONS.document(uid).collection("recent-notifications").document(currentUid).setData(["senderUid": currentUid], completion: completion)
        }
    }
    
    func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("notifications").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                let uid = document.data()["senderUid"] as? String ?? ""
                Service.shared.fetchUser(uid: uid) { user in
                    let notification = Notification(user: user)
                    notifications.append(notification)
                    completion(notifications)
                }
            })
        }
    }
    
    func checkUserIsRequested(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("notifications").document(currentUid).getDocument { snapshot, error in
            if snapshot?.exists == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func fetchNotificationsCount(completion: @escaping(Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("recent-notifications").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: checkNotificationsCount error - \(error.localizedDescription)")
            }
            completion(snapshot?.documents.count ?? 0)
        }
    }
    
    func deleteNotificationsCount(completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("recent-notifications").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ snap in
                snap.reference.delete(completion: completion)
            })
        }
    }
}
