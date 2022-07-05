//
//  RegistrationController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 18.06.22.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .customBlue
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private var profileImage: UIImage?
    
    private lazy var usernameContainerView = InputContainerView(textField: fullnameTextField, shouldHideLabelFlag: true)
    private lazy var fullnameContainerView = InputContainerView(textField: usernameTextField, shouldHideLabelFlag: true)
    
    private let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fullname"
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .customBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleRegister() {
        guard let profileImage = profileImage else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        showLoader(true)
        
        AuthService.shared.createUser(profileImage: profileImage, fullname: fullname, username: username) { error in
            if let error = error {
                print("DEBUG: error \(error.localizedDescription)")
                self.showLoader(false)
                return
            }
            self.delegate?.authenticationComplete()
            self.showLoader(false)
        }
    }
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        plusPhotoButton.setDimensions(width: 180, height: 180)
        
        let stack = UIStackView(arrangedSubviews: [fullnameContainerView, usernameContainerView])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(continueButton)
        continueButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32, height: 48)
    }
}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.profileImage = image
        
        plusPhotoButton.layer.cornerRadius = 180 / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        plusPhotoButton.imageView?.clipsToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.customBlue.cgColor
        plusPhotoButton.layer.borderWidth = 3
        self.plusPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
}
