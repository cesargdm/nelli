//
//  WatsonViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit
import Speech
import Alamofire
import AVFoundation
import CoreLocation
import UserNotifications

protocol WatsonDelegate: class {
    func onMoveTo(viewNumber: Int) -> Void
}

class WatsonViewController: UIViewController, BeaconDelegate, SpeechRecoginizerDelegate, TalkDelegate {
    
    weak var delegate: WatsonDelegate?
    
    // This label is an attributed label, meaning that it can handle multiple text styles in the same label
    @IBOutlet weak var mainLabel: UILabel!
    
    // Watson button
    @IBOutlet weak var nelliButton: UIButton!
    
    // Question text
    private var question: String?
    private var currentWorkspaceId: String?
    private var currentBeacon: CLBeacon?
    
    // Pieces variable declaration
    
    
    // CONSTANTS
    private let COLOR_TOP = UIColor(red: 0/255, green: 158/255, blue: 255/255, alpha: 1)
    private let COLOR_BOTTOM = UIColor(red: 0/255, green: 42/255, blue: 69/255, alpha: 1)
    
    private let PROXIMITY_UUID = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
    
    // Beacons manager
    private var beaconsManager: BeaconsManager?
    
    // Speech recognizer
    private var speechRecognizerManager: SpeechRecognizerManager?
    
    // Voice
    var talk: Talk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Talk init
        talk = Talk()
        
        //Init beacons manager
        beaconsManager = BeaconsManager(uuid: PROXIMITY_UUID, beaconIdentifier: "beacon")
        beaconsManager?.delegate = self
        
        // Speech
        speechRecognizerManager = SpeechRecognizerManager()
        speechRecognizerManager?.delegate = self
        
        // Init background gradient
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 18/255, green: 139/255, blue: 219/255, alpha: 1).cgColor,
            UIColor(red: 20/255, green: 155/255, blue: 245/255, alpha: 1).cgColor,
            UIColor(red: 20/255, green: 155/255, blue: 245/255, alpha: 1).cgColor,
            UIColor(red: 15/255, green: 115/255, blue: 181/255, alpha: 1).cgColor
        ]
        
        gradient.frame = self.view.bounds // Set gradient view bounds
        self.view.layer.insertSublayer(gradient, at: 0) // Insert gradient sublayer
        
        // Set main label text align
        mainLabel.textAlignment = .center
        
    }
    
    @IBAction func moveTo(_ sender: UIButton) {
        // The tag is like an id defined in the storyboard
        let tag = sender.tag
        delegate?.onMoveTo(viewNumber: tag)
    }
    
    func didFinishPlaying(succesfully: Bool) {
        print("Did finish playing")
    }
    
    func didChangeAuthorization(_ authorized: Bool) {
        print("Did change authorization")
    }
    
    func didOutputText(_ text: String?) {
        print("Did output text")
    }
    
    func availabilityDidChange(_ available: Bool) {
        print("Availability did change")
    }
    
    func didEndListening() {
        print("Did end listening")
    }
    
    func didStartListening() {
        print("Did start listening")
    }
    
    func didFoundClosestBeacon(_ beacon: CLBeacon?) {
        
        let pieces = Piece.getPieces()
        
        if (beacon != nil) {
            if let piece = pieces[Int(beacon!.major)]?[Int(beacon!.minor)] {
                
                print(currentWorkspaceId != piece.workspaceId)
                
                // Send notification is we find other piece (beacon)
                if (currentWorkspaceId != piece.workspaceId) {
                    print("Sending notification...")
                    let content = UNMutableNotificationContent()
                    content.title = "¡Pregunta!"
                    content.body = "Estás cerca de la pieza \(piece.title), empieza a preguntar"
                    
                    let request = UNNotificationRequest(identifier: "closeToPiece", content: content, trigger: nil)
                    
                    let center = UNUserNotificationCenter.current()
                    center.add(request, withCompletionHandler: { error in
                        if let error = error {
                            print("ERROR IN REQUEST \(error)")
                        }
                    })
                    
                }
                
                // Set workspaceId
                self.currentWorkspaceId = piece.workspaceId
                
                // Set label's text and alpha
                setLabelText(text: piece.title, room: piece.room.stringValue, alpha: 1)
                
                // Change alpha based on proximity
                switch beacon!.proximity {
                case .far:
                    self.setLabelAlpha(0.4) // Indicate that the piece is far
                case .unknown:
                    self.setLabelAlpha(0.2) // Disable the button since it's in a unstable distance
                    self.nelliButton.isEnabled = false
                default: //Near and inmediate
                    self.setLabelAlpha(1)
                    self.nelliButton.isEnabled = true
                }
            }
        } else {
            // If we dont't have a closet beacon invite to move around
            setLabelText(text: "Acércate a una pieza para preguntarle a Nelli", room: nil, alpha: 0.7)
        }
    }
    
    func setLabelAlpha(_ alpha: Float) {
        UIView.animate(withDuration: 1.0) {
            self.mainLabel.alpha = CGFloat(alpha)
        }
    }
    
    func setLabelText(text: String?, room: String?, alpha: Float?) {
        mainLabel.text = "\(text ?? "")\n\(room ?? "")"
        if let alpha = alpha {
            setLabelAlpha(alpha)
        }
    }
    
    // MARK: Pieces Initalization
}
