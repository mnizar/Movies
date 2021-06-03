//
//  UIViewControllerExtension.swift
//  Movies
//
//  Created by Muhammad Nizar on 03/06/21.
//

import UIKit

extension UIViewController {
    
    /*
     The name of the nib file needs to be the same as the name of the class
     */
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}
