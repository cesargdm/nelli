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
        
        let watsonViewController = storyBoard.instantiateViewController(withIdentifier: "WatsonViewController") as! WatsonViewController
        let piecesViewController = storyBoard.instantiateViewController(withIdentifier: "PiecesViewController") as! PiecesViewController
        let mapViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        
        print("WIDTH \(width)")
        print("HEIGHT \(height)")
        
        containerScrollView.contentSize = CGSize(width: 3*width, height: height)
        containerScrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
        
        let viewControllers = [piecesViewController, watsonViewController, mapViewController]
        
        for (index, viewController) in viewControllers.enumerated() {
            addChildViewController(viewController)
            let originX = CGFloat(index)*width
            viewController.view.frame = CGRect(x: originX, y: 0, width: width, height: height)
            containerScrollView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
            viewController.view.setNeedsLayout()
            viewController.view.setNeedsUpdateConstraints()
            viewController.view.layoutIfNeeded()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

