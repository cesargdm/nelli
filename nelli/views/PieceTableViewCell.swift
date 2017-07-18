//
//  PieceTableViewCell.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class PieceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pieceImageView: UIImageView!
    @IBOutlet weak var pieceTitleLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    
    var piece: Piece?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(pieceTitle piece: String, room: String) {
        pieceTitleLabel.text = piece
        roomLabel.text = room
        pieceImageView.image = UIImage(named: piece)
    }

}
