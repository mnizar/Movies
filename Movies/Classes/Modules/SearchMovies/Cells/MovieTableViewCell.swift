//
//  MovieTableViewCell.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var showNameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var shadowPosterView: UIView!
    @IBOutlet weak var containerPosterView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showNameLabel.numberOfLines = 1
        yearLabel.numberOfLines = 1
        
        shadowPosterView.layer.shadowColor = Constants.Colors.C4C4C4.color().withAlphaComponent(0.7).cgColor
        shadowPosterView.layer.shadowOffset = CGSize.zero
        shadowPosterView.layer.shadowOpacity = 0.7
        shadowPosterView.layer.shadowRadius = 4.0
        shadowPosterView.layer.cornerRadius = 10
        
        containerPosterView.makeItRounded(width: 0.0, borderColor: UIColor.clear.cgColor, cornerRadius: 10) 
    }
    
    func configureWithCellModel(_ cellModel: SearchMoviesContentCellModel?) {
        if let data = cellModel?.data as? SearchModel {
            showNameLabel.numberOfLines = 3
            yearLabel.numberOfLines = 1
            
            showNameLabel.text = data.title
            yearLabel.text = data.year
            posterImageView.setImage(data.posterUrl ?? "")
        }
    }
}
