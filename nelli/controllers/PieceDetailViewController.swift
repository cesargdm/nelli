//
//  PieceDetailViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/19/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class PieceDetailViewController: UIViewController {
    
    @IBOutlet weak var pieceImageView: UIImageView!
    @IBOutlet weak var pieceRoomLabel: UILabel!
    @IBOutlet weak var pieceTitleLabel: UILabel!
    
    var piece: Piece?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieceTitleLabel.text = piece?.title
        pieceRoomLabel.text = piece?.room.stringValue
        
        pieceImageView.image = UIImage(named: piece?.title ?? "")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
