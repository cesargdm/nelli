//
//  WatsonViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

protocol WatsonDelegate: class {
    func onMoveTo(viewNumber: Int) -> Void
}

class WatsonViewController: UIViewController {
    
    weak var delegate: WatsonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func moveToPieces(_ sender: Any) {
        print("Sending move...")
        delegate?.onMoveTo(viewNumber: 0)
    }
    
    @IBAction func moveToMap(_ sender: Any) {
        print("Sending move...")
        delegate?.onMoveTo(viewNumber: 2)
    }
    
    
}
