//
//  SmsCodeController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 17.06.22.
//

import UIKit
import Firebase

class SmsCodeController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private lazy var containerView = InputContainerView(textField: smsCodeTextField, shouldHideLabelFlag: true)
    
    private let smsCodeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter code"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .customBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleLogin() {
        verifyCode()
        showLoader(true)
    }
    
    // MARK: - API
    
    func verifyCode() {
        let smsCode = smsCodeTextField.text!
        AuthService.shared.verifyCode(smsCode: smsCode) { success in
            guard success else { return }
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Service.shared.checkUserIsRegistered(uid: uid) { userIsRegistered in
                if userIsRegistered {
                    self.delegate?.authenticationComplete()
                    self.showLoader(false)
                } else {
                    let controller = RegistrationController()
                    controller.delegate = self.delegate
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.showLoader(false)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32, height: 56)
        
        view.addSubview(continueButton)
        continueButton.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32, height: 48)
    }
}
