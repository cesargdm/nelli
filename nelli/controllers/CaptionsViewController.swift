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
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    var question: String?
    var answer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 20
        
        answerLabel.text = answer
        questionLabel.text = question
    }

    @IBAction func dimiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
