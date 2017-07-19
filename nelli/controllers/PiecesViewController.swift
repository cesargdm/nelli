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
    
    weak var delegate: WatsonDelegate?
    let pieces = Piece.getPieces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        piecesTableView.delegate = self
        piecesTableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        delegate?.onMoveTo(viewNumber: 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pieces[section]?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pieces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pieceCell", for: indexPath) as! PieceTableViewCell
        
        let piece = pieces[indexPath.section]?[indexPath.row]
        
        // Set cell info
        cell.setData(pieceTitle: piece?.title ?? "", room: piece?.room.stringValue ?? "")
        cell.piece = piece
        
        return cell
    }

}
