//
//  PiecesViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class PiecesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var piecesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        piecesTableView.delegate = self
        piecesTableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pieceCell", for: indexPath) as! PieceTableViewCell
        
        cell.mainView.layer.cornerRadius = 10
        
        cell.pieceImageView.layer.cornerRadius = 10
        
        // Set shadow
        cell.mainView.layer.shadowColor = UIColor.black.cgColor
        cell.mainView.layer.shadowOpacity = 0.3
        cell.mainView.layer.shadowOffset = CGSize.zero
        cell.mainView.layer.shadowRadius = 4
        
        return cell
    }

}
