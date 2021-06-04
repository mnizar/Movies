//
//  UIImageViewExtension.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation
import Kingfisher

extension UIImageView {
    
    func setImage(_ url: String, placeholder: String? = "placeholderImage") {
        self.kf.setImage(with: URL(string: url), placeholder: UIImage(named: placeholder!))
    }
}
