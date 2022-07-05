//
//  ProfileController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import UIKit
import SDWebImage
import Firebase

protocol ProfileControllerDelegate: AnyObject {
    func handleRemoveFriend(_ user: User)
    func handleLogout()
}

class ProfileController: UIViewController {
    
    // MARK: - Properties
    
    private var user: User {
        didSet { configure() }
    }
    
    weak var delegate: ProfileControllerDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "arrow.backward", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.setBorder(borderColor: .white, borderWidth: 4)
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var editProfileAddFriendButton: UIButton = {
        let button = buttonMaker(title: "Loading", titleColor: .white)
        button.addTarget(self, action: #selector(handleEditProfileAddFirend), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageLogoutButton: UIButton = {
        let button = buttonMaker(title: "Loading", titleColor: .white)
        button.addTarget(self, action: #selector(handleMessageLogout), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configure()
        checkUserIsFriend()
        checkUserIsRequested()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Selectors
    
    @objc func handleEditProfileAddFirend() {
        if user.isFriend && !user.isCurrentUser {
            let alert = UIAlertController(title: nil, message: "Are you sure you want to remove from friends?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remove from Friends", style: .destructive, handler: { _ in
                self.dismiss(animated: true) {
                    self.delegate?.handleRemoveFriend(self.user)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
        
        if !user.isCurrentUser && !user.isRequested && !user.isFriend {
            NotificationService.shared.uploadNotification(uid: user.uid) { error in
                if let error = error {
                    print("DEBUG: Error is \(error.localizedDescription)")
                    return
                }
                self.user.isRequested = true
            }
        }
    }
    
    @objc func handleMessageLogout() {
        if user.isCurrentUser {
            let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                self.dismiss(animated: true) {
                    self.delegate?.handleLogout()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        } else {
            let controller = ChatController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
        
    // MARK: - API
    
    func checkUserIsFriend() {
        Service.shared.checkUserIsFriend(uid: user.uid) { isFriend in
            self.user.isFriend = isFriend
            print("DEBUG: User isfriend- \(self.user.isFriend)")
        }
    }
    
    func checkUserIsRequested() {
        NotificationService.shared.checkUserIsRequested(uid: user.uid) { isRequested in
            self.user.isRequested = isRequested
            print("DEBUG: User isrequest- \(self.user.isRequested)")
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        profileImageView.setDimensions(width: 200, height: 200)
        profileImageView.layer.cornerRadius = 200 / 2
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: containerView.bottomAnchor, paddingTop: -50)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        view.addSubview(stack)
        stack.centerX(inView: profileImageView)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 16)
        
        let buttonStack = UIStackView(arrangedSubviews: [editProfileAddFriendButton, messageLogoutButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        
        view.addSubview(buttonStack)
        buttonStack.centerX(inView: profileImageView, topAnchor: stack.bottomAnchor, paddingTop: 16)
        buttonStack.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
    }
    
    func configure() {
        guard let url = URL(string: user.profileImageUrl) else { return }
        let viewModel = ProfileViewModel(user: user)
        
        profileImageView.sd_setImage(with: url)
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
        
        messageLogoutButton.isHidden = viewModel.shouldShowMessageButton
        messageLogoutButton.setTitle(viewModel.messageLogoutButtonTitle, for: .normal)
        messageLogoutButton.backgroundColor = viewModel.messageLogoutButtonColor
        
        editProfileAddFriendButton.setTitle(viewModel.editProfileAddFriendButtonTitle, for: .normal)
    }
    
    func buttonMaker(title: String, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .customBlue
        button.setHeight(height: 48)
        button.layer.cornerRadius = 10
        return button
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ProfileController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
