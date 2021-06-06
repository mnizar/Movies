//
//  Constants.swift
//  Movies
//
//  Created by Muhammad Nizar on 03/06/21.
//

import UIKit

struct Constants {
    
    static let realmSchemaVersion = 1
    
    enum Colors: String {
        case C4C4C4 = "#c4c4c4"
        case F3F3F3 = "#f3f3f3"
        case D90016 = "#d90016"

        func color() -> UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
}
