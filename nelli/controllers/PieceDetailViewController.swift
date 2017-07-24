//
//  PieceDetailViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/19/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class PieceDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var pieceTableView: UITableView!
    var piece: Piece?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieceTableView.delegate = self
        pieceTableView.dataSource = self

        // Set auto height for rows
        pieceTableView.estimatedRowHeight = 44
        pieceTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! PieceTableViewCell
            cell.setData(pieceTitle: piece?.title ?? "", room: piece?.room.stringValue ?? "")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }

}
