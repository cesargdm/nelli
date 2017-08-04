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
        
        // Add refresh control
        piecesTableView.refreshControl = refreshControl

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "pieceDetailSegue":
            let destionation = segue.destination as! PieceDetailViewController
            let sender = sender as! PieceTableViewCell
            
            if let piece =  sender.piece {
                destionation.piece = piece
            }
            
        default:
            return
        }
    }
    
    @objc
    private func reloadPieces() {
        refreshControl.attributedTitle = NSAttributedString(string: ReloadMessage.random(), attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.refreshControl.endRefreshing()
            
            self.refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        })
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadPieces), for: UIControlEvents.valueChanged)
        
        // Set title
        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        
        // Set background black
        refreshControl.backgroundColor = UIColor.black
        return refreshControl
    }()

}
