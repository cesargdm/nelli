//
//  ViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let watsonViewController = storyBoard.instantiateViewController(withIdentifier: "WatsonViewController")
        let piecesViewController = storyBoard.instantiateViewController(withIdentifier: "PiecesViewController")
        let mapViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController")
        
        // Add in each view to the container view
        self.containerScrollView.addSubview(piecesViewController.view)
        self.containerScrollView.addSubview(watsonViewController.view)
        self.containerScrollView.addSubview(mapViewController.view)
        
        let containerHeight = view.layer.frame.height
        let containerWidth = view.layer.frame.width
        
        // Set size and positions
        let piecesFrame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        piecesViewController.view.frame = piecesFrame
        
        let watsonFrame = CGRect(x: containerWidth, y: 0, width: containerWidth, height: containerHeight)
        watsonViewController.view.frame = watsonFrame
        
        let mapFrame = CGRect(x: containerWidth*2, y: 0, width: containerWidth, height: containerHeight)
        mapViewController.view.frame = mapFrame
        
        // Set the size of the container scroll view
        self.containerScrollView.contentSize = CGSize(width: containerWidth*3, height: containerHeight)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

