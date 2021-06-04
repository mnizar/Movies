//
//  UIButtonExtension.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import UIKit


extension UIButton {
    
    func buttonWithBorderOny(color: UIColor, cornerRadius: CGFloat = 5.0) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = .white
        self.setTitleColor(color, for: .normal)
    }
    
}
