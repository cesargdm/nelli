//
//  MapViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

struct PieceIconView {
    let view: UIView
    let intialOrigin: CGPoint
    var origin: CGPoint {
        return view.frame.origin
    }
    var width: CGFloat {
        return view.frame.width
    }
    
    init(name: String, size: CGFloat, position: CGPoint) {
        self.intialOrigin = position
        self.view = UIView(frame: CGRect(x: position.x-(size/2), y: position.y-(size/2), width: size, height: size))
        self.view.backgroundColor = .black
        
        self.view.layer.cornerRadius = size/2
        self.view.layer.borderWidth = 5
        self.view.layer.borderColor = UIColor.white.cgColor
        
        self.view.clipsToBounds = false
        
        let label = UILabel(frame: CGRect(x: -75+(self.width/2), y: 55, width: 150, height: 30))
        label.text = name
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(red: 3/255, green: 52/255, blue: 89/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16, weight: 600)

        let imageView = UIImageView(image: UIImage(named: name))
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = self.view.frame.size
        imageView.frame.origin = CGPoint(x: 0, y: 0)
        imageView.layer.cornerRadius = self.width/2
        imageView.clipsToBounds = true
        
        self.view.layer.cornerRadius = size/2
        
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        
    }
}

class MayaMapManager: NSObject, UIScrollViewDelegate {
    let salaMayaMap = UIImageView(image: UIImage(named: "sala-maya"))
    var scrollView: UIScrollView?
    
    let iconsSize: CGFloat = 60
    let test = UIView()
    
    var pieceIcons: [PieceIconView] = []
    
    func set(_ scrollView: UIScrollView, mapWidth: CGFloat, pieceIcons: [PieceIconView]) {
        salaMayaMap.clipsToBounds = false
        salaMayaMap.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapWidth)
        
        self.pieceIcons = pieceIcons
        
        for pieceIcon in self.pieceIcons {
            scrollView.addSubview(pieceIcon.view)
            scrollView.bringSubview(toFront: pieceIcon.view)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scale = scrollView.zoomScale

        for pieceIcon in pieceIcons {
            pieceIcon.view.frame.origin = CGPoint(
                x: pieceIcon.intialOrigin.x*scale-(pieceIcon.width/2),
                y: pieceIcon.intialOrigin.y*scale-(pieceIcon.width/2)
            )
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return salaMayaMap
    }
}

class MapViewController: UIViewController, UIScrollViewDelegate {
    
    weak var delegate: WatsonDelegate?
    @IBOutlet weak var mapScrollView: UIScrollView!
    
    var mayaMapManager = MayaMapManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = self.view.frame.width

        mapScrollView.contentSize.width = viewWidth*2
        
        let scrollSalaMayaMap = UIScrollView()
        
        let pieceIcons = [
            PieceIconView(name: "Dintel 26", size: 60, position: CGPoint(x: 188, y: 165)),
             PieceIconView(name: "Chac Mool", size: 60, position: CGPoint(x: 330, y: 180)),
             PieceIconView(name: "Tumba de Pakal", size: 60, position: CGPoint(x: 188, y: 245)),
             PieceIconView(name: "Friso Estucado", size: 60, position: CGPoint(x: 330, y: 255))
        ]
        
        mayaMapManager.set(scrollSalaMayaMap, mapWidth: viewWidth, pieceIcons: pieceIcons)
        
        scrollSalaMayaMap.delegate = mayaMapManager
        scrollSalaMayaMap.minimumZoomScale = 1.0
        scrollSalaMayaMap.maximumZoomScale = 5.0
        scrollSalaMayaMap.alwaysBounceVertical = true
        scrollSalaMayaMap.showsVerticalScrollIndicator = true
        scrollSalaMayaMap.flashScrollIndicators()
        scrollSalaMayaMap.frame = CGRect(x: 0, y: 0, width: viewWidth, height: mapScrollView.frame.height)
        scrollSalaMayaMap.contentSize = CGSize(width: viewWidth, height: viewWidth)
        scrollSalaMayaMap.addSubview(mayaMapManager.salaMayaMap)
        scrollSalaMayaMap.sendSubview(toBack: mayaMapManager.salaMayaMap)
        
        
        let salaMexicaMap = UIImageView(image: UIImage(named: "sala-maya"))
        salaMexicaMap.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewWidth)
        
        let salaMayaLabel = UILabel(frame: CGRect(x: viewWidth - 160, y: 0, width: viewWidth, height: 40))
        salaMayaLabel.text = "Sala Maya"
        salaMayaLabel.font = UIFont.systemFont(ofSize: 30, weight: 600)
        salaMayaLabel.textColor = .white
        
        mapScrollView.addSubview(scrollSalaMayaMap)
        mapScrollView.addSubview(salaMayaLabel)
        mapScrollView.addSubview(salaMexicaMap)
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        delegate?.onMoveTo(1)
    }
    
}
