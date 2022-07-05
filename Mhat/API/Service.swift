//
//  Service.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 18.06.22.
//

import Firebase
import CoreLocation

class Service {
    static let shared = Service()
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { snapshot, error in
            guard var users = snapshot?.documents.map({ User(dictionary: $0.data()) }) else { return }
            
//            if let index = users.firstIndex(where: { $0.uid == Auth.auth().currentUser?.uid }) {
//                users.remove(at: index)
//            }
            
            for user in users {
                self.fetchLocations(uid: user.uid) { location in
                    guard let i = users.firstIndex(where: { $0.uid == user.uid }) else { return }
                    users[i].location = location
                    completion(users)
                }
            }
        }
    }
    
    func fetchFriends(completion: @escaping([User]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FRIENDS.document(currentUid).collection("friends").getDocuments { snapshot, error in
            guard var users = snapshot?.documents.map({ User(dictionary: $0.data()) }) else { return }
            
            for user in users {
                self.fetchLocations(uid: user.uid) { location in
                    guard let i = users.firstIndex(where: { $0.uid == user.uid }) else { return }
                    users[i].location = location
                    completion(users)
                }
            }
        }
    }
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    func checkUserIsRegistered(uid: String, completion: @escaping(Bool) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            if snapshot?.exists == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkUserIsFriend(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FRIENDS.document(currentUid).collection("friends").document(uid).getDocument { snapshot, error in
            if snapshot?.exists == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
        
    func updateLocation(coordinate: CLLocationCoordinate2D, completion: ((Error?) -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let latitude = coordinate.latitude as? Double else { return }
        guard let longitude = coordinate.longitude as? Double else { return }
        
        let data = ["latitude": "\(latitude)",
                    "longitude": "\(longitude)"] as [String: Any]
        
        COLLECTION_LOCATIONS.document(uid).setData(data, completion: completion)
    }
    
    func fetchLocations(uid: String, completion: @escaping(CLLocationCoordinate2D) -> Void) {
        
        COLLECTION_LOCATIONS.document(uid).addSnapshotListener { snapshot, error in
            guard let latitude = snapshot?.data()?["latitude"] as? String else { return }
            guard let longitude = snapshot?.data()?["longitude"] as? String else { return }
            let location = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
            completion(location)
        }
    }
    
    func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return  }
        
        let data = ["text": message,
                    "fromId": currentUid,
                    "toId": user.uid,
                    "timestamp": Timestamp(date: Date())] as [String: Any]
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
            
            COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
            
            COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
        }
    }
    
    func fetchMessages(forUser user: User, completion: @escaping([Message]) -> Void) {
        var messages = [Message]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp")
        query.addSnapshotListener { snapshot, error in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    let message = Message(dictionary: dictionary)
                    messages.append(message)
                    completion(messages)
                }
            })
        }
    }
    
    func confirmRequest(uid: String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.fetchUser(uid: currentUid) { user in
            let currentUserData = ["phoneNumber": user.phoneNumber,
                                   "fullname": user.fullname,
                                   "username": user.username,
                                   "profileImageUrl": user.profileImageUrl,
                                   "uid": currentUid] as [String: Any]
            
            self.fetchUser(uid: uid) { user in
                let userData = ["phoneNumber": user.phoneNumber,
                                "fullname": user.fullname,
                                "username": user.username,
                                "profileImageUrl": user.profileImageUrl,
                                "uid": uid] as [String: Any]
                
                COLLECTION_FRIENDS.document(currentUid).collection("friends").document(uid).setData(userData) { _ in
                    COLLECTION_FRIENDS.document(uid).collection("friends").document(currentUid).setData(currentUserData) { _ in
                        COLLECTION_NOTIFICATIONS.document(currentUid).collection("notifications").document("\(uid)").delete(completion: completion)
                    }
                }
            }
        }
    }
    
    func removeUserFromFriends(uid: String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FRIENDS.document(currentUid).collection("friends").document(uid).delete { _ in
            COLLECTION_FRIENDS.document(uid).collection("friends").document(currentUid).delete(completion: completion)
        }
    }
    
    func deleteRequest(uid: String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("notifications").document("\(uid)").delete(completion: completion)
    }
}
