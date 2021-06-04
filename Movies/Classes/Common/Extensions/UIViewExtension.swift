//
//  UIViewExtension.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import UIKit

extension UIView {
    func makeItRounded(width: CGFloat = 0, borderColor: CGColor = UIColor.clear.cgColor, cornerRadius: CGFloat = 0){
        self.layer.borderWidth = width
        self.layer.masksToBounds = false
        self.layer.borderColor = borderColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}
