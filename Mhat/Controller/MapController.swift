//
//  MapController.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 14.06.22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth
import SDWebImage

class MapController: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    private var locationManager = CLLocationManager()
    private var userLocation = CLLocationCoordinate2D()

    private var userAnnotation = MKPointAnnotation()
    
    private var annotations = [MKPointAnnotation]() {
        didSet { configureMapView() }
    }
        
    private var users: [User]? {
        didSet {
            fetchLocations()
        }
    }
    
    private var isUserLocate = false
        
    private let notificationCountLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemRed
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.setDimensions(width: 18, height: 18)
        label.setBorder(borderColor: .white, borderWidth: 2)
        label.clipsToBounds = true
        label.layer.cornerRadius = 18 / 2
        return label
    }()
    
    private lazy var notificationButton: UIButton = {
        let button = buttonMaker(iconName: "bell.fill")
        button.addSubview(notificationCountLabel)
        notificationCountLabel.anchor(top: button.topAnchor, right: button.rightAnchor, paddingTop: 7, paddingRight: 7)
        
        button.addTarget(self, action: #selector(showNotificationController), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = buttonMaker(iconName: "magnifyingglass")
        
        button.addTarget(self, action: #selector(showSearchController), for: .touchUpInside)
        return button
    }()
    
    private lazy var locationButton: UIButton = {
        let button = buttonMaker(iconName: "location.fill")
        
        button.addTarget(self, action: #selector(updateMyLocation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        authenticateUserAndConfigureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        //fetchUser()
        fetchFriends()
        fetchNotificationsCount()
    }
    
    // MARK: - Selectors
    
    @objc func updateMyLocation() {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func showNotificationController() {
        let controller = NotificationController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func showSearchController() {
        let controller = SearchUserController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - API
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            authenticateUserAndConfigureUI()
        } catch {
            print("DEBUG: Error..")
        }
    }
    
    func fetchFriends() {
        Service.shared.fetchFriends { users in
            self.users = users
        }
    }
    
    func fetchLocations() {
        users?.forEach({ user in
            guard let location = user.location else { return }
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.subtitle = user.uid
            let i = annotations.firstIndex(where: { $0.subtitle == user.uid })
            if i == nil {
//                let allAnnotations = mapView.annotations
//                mapView.removeAnnotations(allAnnotations)
                self.annotations.append(annotation)
                
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.annotations[i!].coordinate = location
                }
            }
        })
    }
    
    func updateLocation() {
        guard Auth.auth().currentUser?.uid != nil else { return }
        Service.shared.updateLocation(coordinate: userLocation) { error in
            if let error = error {
                print("DEBUG: Error qaqo \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNotificationsCount() {
        notificationCountLabel.isHidden = true
        NotificationService.shared.fetchNotificationsCount { notificationCount in
            if notificationCount != 0 {
                self.notificationCountLabel.isHidden = false
                print("DEBUG: qaqam count \(notificationCount)")
                self.notificationCountLabel.text = "\(notificationCount)"
            }
        }
    }
    
    // MARK: - Helpers
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureMapView()
            //fetchUser()
            fetchFriends()
            fetchNotificationsCount()
        }
    }
    
    func configureMapView() {
        mapView.delegate = self
        locationManager.delegate = self
        mapView.showsCompass = false
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: "identifier")
        view.addSubview(mapView)
        mapView.addConstraintsToFillView(view)
        
        mapView.addAnnotations(annotations)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        configureUI()
    }
    
    func configureUI() {
        
        
        view.addSubview(locationButton)
        locationButton.centerY(inView: view)
        locationButton.anchor(right: view.rightAnchor, paddingRight: 16)
                
        view.addSubview(notificationButton)
        notificationButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
        
        view.addSubview(searchButton)
        searchButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 8, paddingRight: 12)
    }
    
    func refreshMapView() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.users?.removeAll()
        self.annotations.removeAll()
        self.fetchFriends()
    }
}

// MARK: - MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "identifier", for: annotation) as! CustomAnnotationView

        guard let index = users?.firstIndex(where: { $0.uid == annotation.subtitle }) else { return nil }
                
        annotationView.user = users?[index]
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let index = users?.firstIndex(where: { $0.uid == view.annotation?.subtitle }) else { return }
        guard let user = users?[index] else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if user.uid == currentUid {
            let controller = ProfileController(user: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = ChatController(user: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
            navigationController?.navigationBar.isHidden = false
        }    
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        if !isUserLocate {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(region, animated: true)
            isUserLocate = true
        }
        userAnnotation.coordinate = userLocation
        self.updateLocation()
    }
}

// MARK: - AuthenticationDelegate

extension MapController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true, completion: nil)
        configureMapView()
        fetchFriends()
    }
}

// MARK: - ProfileControllerDelegate

extension MapController: ProfileControllerDelegate {
    func handleRemoveFriend(_ user: User) {
        let uid = user.uid
        navigationController?.popToRootViewController(animated: true)
        Service.shared.removeUserFromFriends(uid: uid) { error in
            if error == nil {
                self.refreshMapView()
            }
        }
    }
    
    func handleLogout() {
        navigationController?.popToRootViewController(animated: true)
        logOut()
    }
}

// MARK: - CustomFunctions

extension MapController {
    func buttonMaker(iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: iconName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .customBlue
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.setDimensions(width: 48, height: 48)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 48 / 2
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .init(width: 0, height: 0)
        button.layer.shadowColor = UIColor.lightGray.cgColor
        return button
    }

}
