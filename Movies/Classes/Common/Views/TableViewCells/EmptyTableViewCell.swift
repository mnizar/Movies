//
//  EmptyTableViewCell.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import UIKit

protocol EmptyTableViewCellDelegate: AnyObject {
    func retryButtonDidClicked()
}

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var retryButton: UIButton!
    
    weak var delegate: EmptyTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        retryButton.buttonWithBorderOny(color: Constants.Colors.D90016.color())
    }
    
    func configureCell(_ message:String?, imageName: String?) {
        infoLabel.text = message
        infoImageView.image = UIImage(named: imageName ?? "placeholderImage")
    }
    
    @IBAction func retryButtonAction() {
        delegate?.retryButtonDidClicked()
    }
}
