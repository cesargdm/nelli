//
//  CaptionsViewController.swift
//  nelli
//
//  Created by César Guadarrama on 8/18/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class CaptionsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var question = ""
    var answer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 20
    }

    @IBAction func dimiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
