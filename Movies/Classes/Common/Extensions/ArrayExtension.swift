//
//  ArrayExtension.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation

extension Array {
    
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
