//
//  LoadingTableViewCell.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
}
