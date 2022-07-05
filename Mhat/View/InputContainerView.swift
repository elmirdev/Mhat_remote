//
//  InputContainerView.swift
//  Mhat
//
//  Created by ELMIR ISMAYILZADA on 15.06.22.
//

import UIKit

class InputContainerView: UIView {
    
    // MARK: - Properties
    
    private let countryNameLabel: UILabel = {
        let label = UILabel()
        label.text = "+994"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let countryFlag: UIImageView = {
        let image = UIImage(named: "aze")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 22, height: 22)
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    init(textField: UITextField, shouldHideLabelFlag: Bool) {
        super.init(frame: .zero)
        
        setHeight(height: 56)
        backgroundColor = .systemGray7
        layer.cornerRadius = 10
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.systemGray6.cgColor
        
        let stack = UIStackView(arrangedSubviews: [countryFlag, countryNameLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.isHidden = shouldHideLabelFlag
        stack.setWidth(width: 70)
        
        let fullStack = UIStackView(arrangedSubviews: [stack, textField])
        fullStack.spacing = 8
        fullStack.axis = .horizontal
        
        addSubview(fullStack)
        fullStack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 8, paddingRight: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
