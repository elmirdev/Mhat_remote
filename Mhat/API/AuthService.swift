//
//  AuthService.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 17.06.22.
//

import Foundation
import Firebase

class AuthService {
    static let shared = AuthService()
    
    private var verificationId: String?
    
    func startAuth(phoneNumber: String, completion: @escaping(Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            self?.verificationId = verificationId
            completion(true)
        }
    }
    
    func verifyCode(smsCode: String, completion: @escaping(Bool) -> Void) {
        guard let verificationId = verificationId else {
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        
        Auth.auth().signIn(with: credential) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func createUser(profileImage: UIImage,fullname: String, username: String, completion: ((Error?) -> Void)?) {
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { meta, error in
            if let error = error {
                completion!(error)
                return
            }
            
            ref.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                guard let currentUid = Auth.auth().currentUser?.uid else { return }
                guard let phoneNumber = Auth.auth().currentUser?.phoneNumber else { return }
                
                let data = ["phoneNumber": phoneNumber,
                            "fullname": fullname,
                            "username": username,
                            "profileImageUrl": profileImageUrl,
                            "uid": currentUid] as [String: Any]
                
                COLLECTION_USERS.document(currentUid).setData(data) { _ in
                    COLLECTION_FRIENDS.document(currentUid).collection("friends").document(currentUid).setData(data) { _ in
                        COLLECTION_USERSNAMES.document(username).setData(["uid": currentUid] as [String: Any], completion: completion)
                    }
                }
                
            }
        }
    }
}
