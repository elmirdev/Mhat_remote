//
//  CustomAnnotationView.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 15.06.22.
//

import UIKit
import MapKit
import SDWebImage

class CustomAnnotationView: MKAnnotationView {
    
    // MARK: - Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    private let animationView: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue
        view.clipsToBounds = true
        view.setDimensions(width: 60, height: 60)
        view.layer.cornerRadius = 60 / 2
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.customBlue.cgColor
        iv.layer.borderWidth = 4.0
        iv.backgroundColor = .lightGray
        iv.setDimensions(width: 60, height: 60)
        iv.layer.cornerRadius = 60 / 2
        //iv.image = UIImage(named: "spider")
        return iv
    }()
    
    private let usernameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        label.backgroundColor = .customBlue
        return label
    }()

    
    // MARK: - Lifecycle
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setDimensions(width: 80, height: 80)

        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: 0)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        canShowCallout = true
        
        addSubview(animationView)
        animationView.center(inView: self)
        
        addSubview(profileImageView)
        profileImageView.center(inView: self)
        
        addSubview(usernameLabel)
        usernameLabel.centerX(inView: self, topAnchor: topAnchor, paddingTop: -20)
        
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let user = user else { return }
        
        guard let profileImageUrl = URL(string: user.profileImageUrl) else { return }
        
        profileImageView.sd_setImage(with: profileImageUrl)
        
        let viewModel = AnnotationViewModel(user: user)
        
        usernameLabel.text = viewModel.usernameLabel
    }
}
