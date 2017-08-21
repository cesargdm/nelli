//
//  InfoTableViewCell.swift
//  nelli
//
//  Created by IBM Studio on 8/18/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import UIKit

class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var pieceInformation: UILabel!
    
    var piece: Piece?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(_ info: String) {
        infoTitle.text = "Información"
        pieceInformation.text = info
    }
    
}
