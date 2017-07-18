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
    
    // Contants
    let NOTIFICATION_TITLE = "¡Pregunta!"
    let GO_CLOSER = "Acércate a una pieza para preguntarle a Nelli"
    
    weak var delegate: WatsonDelegate?
    
    // Outlets
    @IBOutlet weak var mainLabel: UILabel! // This label is an attributed label, meaning that it can handle multiple text styles in the same label
    @IBOutlet weak var nelliButton: UIButton! // Watson button
    
    // Question text
    private var question: String?
    private var currentWorkspaceId: String?
    
    // CONSTANTS
    private let COLOR_TOP = UIColor(red: 0/255, green: 158/255, blue: 255/255, alpha: 1)
    private let COLOR_BOTTOM = UIColor(red: 0/255, green: 42/255, blue: 69/255, alpha: 1)
    
    private var pieces:[Int:[Piece]] = [Int:[Piece]]()
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
        
        // Setup the pieces array
        pieces = Piece.getPieces()
        
    }
    
    @IBAction func watsonTouched(_ sender: UIButton) {
        do {
            // It will call didEndListenning if the button is pressed and it was allready listening
            try speechRecognizerManager?.startRecording()
        } catch {
            print("Speech recognizer error.\n\(error)")
        }
    }
    
    @IBAction func moveTo(_ sender: UIButton) {
        // The tag is like an id defined in the storyboard
        let tag = sender.tag
        delegate?.onMoveTo(viewNumber: tag)
    }
    
    func didFinishPlaying(succesfully: Bool) {
        // TODO
        // End talking animation
    }
    
    func didChangeAuthorization(_ authorized: Bool) {
        
        // Required to perform in main queue
        OperationQueue.main.addOperation() {
            // Set button isEnabled
            self.nelliButton.isEnabled = authorized
        }
        
    }
    
    func didOutputText(_ text: String?) {
        
        // Set the text into question
        question = text
        mainLabel.text = question
        
    }
    
    func availabilityDidChange(_ available: Bool) {
        print("Availability did change")
    }
    
    func didEndListening() {
        
        // TODO
        // End listening animation
        // Start thinking animation
        // disableButtons()
        
        mainLabel.text = "Pensando...\n\"\(question ?? "")\""
        
        // Check that we have a question text
        if question == nil {
            print("No question")
            return
        } else if currentWorkspaceId == nil { // Check that we have a workspaceId
            print("No workspace")
            return
        } else {
            Watson.textToSpeech(text: question!, workspaceId: currentWorkspaceId!, callback: { (data) in
                if let audioData = data {
                    self.mainLabel.text = "Respondiendo..."
                    self.talk?.play(data: audioData)
                    // TODO
                    // Stop thinking animation
                    // Start talking animation
                } else {
                    // TODO could not get data
                    print("Didn't get data")
                }
            })
        }
        
    }
    
    func didStartListening() {
        // TODO
        // Start listening animation
    }
    
    func didFoundClosestBeacon(_ beacon: CLBeacon?) {
        
        if let beacon = beacon {
            let major = beacon.major.intValue
            let minor = beacon.minor.intValue
            if let piece = pieces[major]?[minor] {
                
                // Send notification is we find other piece (beacon)
                if (currentWorkspaceId != piece.workspaceId) {
                    let content = UNMutableNotificationContent()
                    content.title = NOTIFICATION_TITLE
                    content.body = "Estás cerca de la pieza \(piece.title), empieza a preguntar"
                    
                    let request = UNNotificationRequest(identifier: "closeToPiece", content: content, trigger: nil)
                    
                    let center = UNUserNotificationCenter.current()
                    center.add(request, withCompletionHandler: { error in
                        if let error = error {
                            print("User notification request error.\n\(error)")
                        }
                    })
                    
                }
                
                // Set workspaceId
                self.currentWorkspaceId = piece.workspaceId
                
                // Set label's text and alpha
                setLabelText(text: piece.title, room: piece.room.stringValue, alpha: 1)
                
                // Change alpha based on proximity
                switch beacon.proximity {
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
            // If we dont't have a closet beacon invite to move around and if we dont have a question around
            if (question == nil) {
                setLabelText(text: GO_CLOSER, room: nil, alpha: 0.7)
            }
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
