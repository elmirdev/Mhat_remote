//
//  NotificationController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 21.06.22.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController: UITableViewController {
    
    // MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .customBlue
        button.setDimensions(width: 32, height: 32)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNotifications()
        deleteNotificationsCount()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func fetchNotifications() {
        NotificationService.shared.fetchNotifications { notifications in
            self.notifications = notifications
        }
    }
    
    func deleteNotificationsCount() {
        NotificationService.shared.deleteNotificationsCount { error in
            if error != nil {
                print("DEBUG: Delete notifications count error")
            }
        }
    }
        
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar(withTitle: "Notifications", backgroundColor: .white, prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
//        let refreshControl = UIRefreshControl()
//        tableView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.delegate = self
        cell.notification = notifications[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = notifications[indexPath.row].user
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NotificationController: NotificationCellDelegate {
    func didTapConfirm(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        Service.shared.confirmRequest(uid: user.uid) { error in
            if error == nil {
                self.fetchNotifications()
                if self.notifications.count == 1 {
                    self.notifications.removeAll()
                }
            }
        }
    }
    
    func didTapDelete(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        Service.shared.deleteRequest(uid: user.uid) { error in
            if error == nil {
                self.fetchNotifications()
                if self.notifications.count == 1 {
                    self.notifications.removeAll()
                }
            }
        }
    }
}

