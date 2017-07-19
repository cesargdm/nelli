//
//  ViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WatsonDelegate {
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    // Get the bounds width and height
    let bounds = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instiate view controllers
        let watsonViewController = storyBoard.instantiateViewController(withIdentifier: "WatsonViewController") as! WatsonViewController
        let piecesViewController = storyBoard.instantiateViewController(withIdentifier: "PiecesViewController") as! PiecesViewController
        let mapViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        // Set the view's delegate as this class
        watsonViewController.delegate = self
        piecesViewController.delegate = self
        mapViewController.delegate = self
        
        // Set the view and height to scroll view
        containerScrollView.contentSize = CGSize(width: bounds.width*3, height: bounds.height)
        
        // Move to second position (initial view controller)
        containerScrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        
        // Arrange view controllers in an array for easy use
        let viewControllers = [piecesViewController, watsonViewController, mapViewController]
        
        // Iterate over view controller array
        for (index, viewController) in viewControllers.enumerated() {
            addChildViewController(viewController)
            let originX = CGFloat(index)*bounds.width
            viewController.view.frame = CGRect(x: originX, y: 0, width: bounds.width, height: bounds.height)
            containerScrollView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
        
    }
    
    func onMoveTo(viewNumber: Int) {
        containerScrollView.setContentOffset(CGPoint(x: bounds.width*CGFloat(viewNumber),y: 0), animated: true)
    }
    
}

