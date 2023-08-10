//
//  MyPlantsCell.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 24.06.2023.
//

import UIKit

class MyPlantsCell: UITableViewCell {

    @IBOutlet weak var imageCellView: UIImageView!
    @IBOutlet weak var sunCellLabel: UILabel!
    @IBOutlet weak var waterCellLabel: UILabel!
    @IBOutlet weak var plantSciNameLabel: UILabel!
    @IBOutlet weak var plantNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageCellView.layer.cornerRadius = imageCellView.frame.size.width / 2
        imageCellView.layer.borderWidth = 2.0
        imageCellView.layer.borderColor = UIColor(named: "PlantHouse White")?.cgColor
        plantNameLabel.adjustsFontSizeToFitWidth = true
        plantNameLabel.minimumScaleFactor = 0.2
        plantSciNameLabel.adjustsFontSizeToFitWidth = true
        plantSciNameLabel.minimumScaleFactor = 0.2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
