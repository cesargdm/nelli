//
//  MapViewController.swift
//  mna
//
//  Created by César Guadarrama on 6/21/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.clear
        let blurEffect =
            
            
            UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        
        blurEffectView.frame = view.bounds        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
