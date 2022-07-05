//
//  NotificationCell.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import UIKit
import SDWebImage

protocol NotificationCellDelegate: AnyObject {
    func didTapConfirm(_ cell: NotificationCell)
    func didTapDelete(_ cell: NotificationCell)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var notification: Notification? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
        
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
                
        return iv
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some test notification meessage"
        label.setWidth(width: 150)
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = buttonMaker(title: "Confirm", titleColor: .white, backgroundColor: .customBlue)
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = buttonMaker(title: "Delete", titleColor: .white, backgroundColor: .lightGray)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        let stack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
        stack.spacing = 8
        stack.alignment = .center
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let buttonStack = UIStackView(arrangedSubviews: [confirmButton, deleteButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        
        addSubview(buttonStack)
        buttonStack.centerY(inView: self)
        buttonStack.anchor(right: rightAnchor, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleConfirm() {
        delegate?.didTapConfirm(self)
    }
    
    @objc func handleDelete() {
        delegate?.didTapDelete(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let notification = notification else { return }
        
        profileImageView.sd_setImage(with: URL(string: notification.user.profileImageUrl))
        notificationLabel.text = "\(notification.user.username) sent you a friend request"
    }
}

// MARK: - CustomFunctions

extension NotificationCell {
    func buttonMaker(title: String, titleColor: UIColor, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = backgroundColor
        button.setDimensions(width: 70, height: 28)
        button.layer.cornerRadius = 5
        return button
    }
}
