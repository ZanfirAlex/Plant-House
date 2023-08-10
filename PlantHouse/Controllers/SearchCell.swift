//
//  SearchCell.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 23.06.2023.
//

import UIKit

class SearchCell: UITableViewCell {



    @IBOutlet weak var stackForLoading: UIStackView!
    
    @IBOutlet weak var searchImageView: UIImageView!
    
    @IBOutlet weak var searchNameLabel: UILabel!
    
    @IBOutlet weak var searchSciNameLabel: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
      
        
            }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
