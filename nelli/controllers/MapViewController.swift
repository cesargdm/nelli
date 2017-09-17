//
//  MapViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UIScrollViewDelegate {
    
    weak var delegate: WatsonDelegate?
    @IBOutlet weak var mapImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        
        mapImageView.isUserInteractionEnabled = true
        mapImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        var touchPoint = tapGestureRecognizer.location(in: self.mapImageView)
        
        touchPoint.x = touchPoint.x *  (mapImageView.image?.size.width)! / mapImageView.frame.width
        touchPoint.y = touchPoint.y *  (mapImageView.image?.size.height)! / mapImageView.frame.height
        
        print(touchPoint.x, touchPoint.y)
        
        if (touchPoint.x >= 66 && touchPoint.x <= 160 && touchPoint.y >= 334 && touchPoint.y <= 490) {
            print("Showing sala maya...")
            performSegue(withIdentifier: "mapDetailSegue", sender: "Sala Maya")
        } else if (touchPoint.x >= 160 && touchPoint.x >= 207 && touchPoint.y >= 113 && touchPoint.y <= 265) {
            print("Showing sala mexica...")
            performSegue(withIdentifier: "mapDetailSegue", sender: "Sala Mexica")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapToDisplay = sender as! String
        let destination = segue.destination as! MapDetailViewController
        destination.selectedMap = mapToDisplay
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        delegate?.onMoveTo(viewNumber: 1)
    }
    
}
