//
//  LoginController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 15.06.22.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mhat"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 28)
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private lazy var containerView = InputContainerView(textField: phoneNumberTextField, shouldHideLabelFlag: false)
    
    private let phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter phone number"
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
        button.addTarget(self, action: #selector(handleEnterNumber), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleEnterNumber() {
        startAuth()
    }
    
    // MARK: - API
    
    func startAuth() {
        let phoneNumber = "+994\(phoneNumberTextField.text!)"
        AuthService.shared.startAuth(phoneNumber: phoneNumber) { success in
            guard success else { return }
            
            let controller = SmsCodeController()
            controller.delegate = self.delegate
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [appNameLabel, loginLabel])
        stack.axis = .vertical
        stack.spacing = 32
        
        view.addSubview(stack)
        stack.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 16)
        
        view.addSubview(containerView)
        containerView.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32, height: 56)
        
        view.addSubview(continueButton)
        continueButton.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32, height: 48)
    }
}
