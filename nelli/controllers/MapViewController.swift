//
//  MapViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    weak var delegate: WatsonDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        delegate?.onMoveTo(viewNumber: 1)
    }
    
}
