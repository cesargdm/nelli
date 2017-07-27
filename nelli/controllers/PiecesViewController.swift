//
//  PiecesViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit

class PiecesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerAnimatedTransitioning {
    
    @IBOutlet weak var piecesTableView: UITableView?
    
    weak var delegate: WatsonDelegate?
    let pieces = Piece.getPieces()
    
    let transition = PiceImageAnimator()
    
    var selectedPieceImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        piecesTableView?.delegate = self
        piecesTableView?.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        delegate?.onMoveTo(viewNumber: 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pieces[section]?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pieces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pieceCell", for: indexPath) as! PieceTableViewCell
        
        let piece = pieces[indexPath.section]?[indexPath.row]
        
        // Set cell info
        cell.setData(pieceTitle: piece?.title ?? "", room: piece?.room.stringValue ?? "")
        cell.piece = piece
        
        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "pieceDetailSegue":
            let destionation = segue.destination as! PieceDetailViewController
            let sender = sender as! PieceTableViewCell

            selectedPieceImageView = sender.pieceImageView
            selectedPieceImageView?.frame = sender.frame
            
            destionation.pieceImage = selectedPieceImageView?.image
            
            destionation.transitioningDelegate = self
            
            if let piece =  sender.piece {
                destionation.piece = piece
            }
            
            print(sender.pieceImageView)
            
        default:
            return
        }
    }
    
    // MARK: - Animation
    
    override
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Code
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(
            alongsideTransition: { context in

        },
            completion: nil
        )
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 1
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        
    }

}

class PiceImageAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.6
    var presenting = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // Code
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let fromViewController = transitionContext.viewController(forKey: .from) as! ViewController
        
        let piecesViewController = fromViewController.childViewControllers[0] as! PiecesViewController
        
        let toView = transitionContext.view(forKey: .to)
        let toViewController = transitionContext.viewController(forKey: .to) as! PieceDetailViewController
        
        let selectedImageView = piecesViewController.selectedPieceImageView
        
        // Background view
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        backgroundView.backgroundColor = UIColor.black
        
        let imageWrapper = UIView(frame: CGRect(
            x: selectedImageView!.frame.origin.x,
            y: selectedImageView!.frame.origin.y + 20 + 20,
            width: selectedImageView!.frame.width,
            height: selectedImageView!.frame.height
        ))
        
        let imageView:UIImageView = UIImageView(image: selectedImageView?.image)
        imageView.frame = CGRect(x: 0, y: 0, width: selectedImageView!.frame.width, height: selectedImageView!.frame.height)
        imageView.contentMode = .scaleAspectFill
        
        imageWrapper.addSubview(imageView)
        
        containerView.addSubview(backgroundView)
        containerView.addSubview(imageWrapper)
        
        toView?.alpha = 0.0
        backgroundView.alpha = 0.0
        
        containerView.addSubview(toView!)
        
        // Animate background
        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = 1.0
        }
        
        UIView.animate(withDuration: duration, animations: {
            imageWrapper.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            imageWrapper.frame = CGRect(x: 160, y: 74, width: 200, height: 200)
        }) { finished in
            self.presenting = false
            
            UIView.animate(withDuration: 0.2, animations: {
                toView?.alpha = 1.0
            })
            toViewController.pieceImage = imageView.image
            transitionContext.completeTransition(true)
        }
    
    }
    
}

extension PiecesViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        
        return transition
        
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
