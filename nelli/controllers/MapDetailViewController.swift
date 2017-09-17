//
//  MapDetailViewController.swift
//  nelli
//
//  Created by César Guadarrama on 9/16/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class MapDetailViewController: UIViewController {
    
    var selectedMap: String?
    @IBOutlet weak var mapDetailImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleBarLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        titleBarLabel.text = selectedMap
        
        if let selected = selectedMap {
          mapDetailImageView.image = UIImage(named: selected)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
