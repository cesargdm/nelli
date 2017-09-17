//
//  WatsonViewController.swift
//  nelli
//
//  Created by César Guadarrama on 7/12/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import CoreLocation
import UserNotifications
import Alamofire

enum WatsonState: Int {
    case idle = 0, listening, thinking, talking, error
}

func printTimeStamp() {
    let d = Date()
    let df = DateFormatter()
    df.dateFormat = "y-MM-dd H:m:ss.SSSS"
    
    print("TIME STAMP:" + df.string(from: d))
}

class WatsonViewController: UIViewController, BeaconDelegate, SpeechRecoginizerDelegate, TalkDelegate {
    
    // Contants
    let NOTIFICATION_TITLE = "¡Pregunta!"
    let GO_CLOSER = "Acércate a una pieza para preguntar"
    
    // Delegate
    weak var delegate: WatsonDelegate?
    
    // Outlets
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var mainLabel: UILabel! // This label is an attributed label, meaning that it can handle multiple text styles in the same label
    @IBOutlet weak var showTextView: UIView!
    @IBOutlet weak var nelliButton: UIButton! // Watson button
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var discoverLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var inahImageView: UIImageView!
    @IBOutlet weak var ibmImageView: UIImageView!
    
    // Question text
    private var answer: String?
    private var question: String?
    private var currentWorkspaceId: String?
    
    // Variables
    var watsonState: WatsonState = .idle
    var request: Alamofire.Request?
    
    // CONSTANTS
    private var pieces = Piece.getPieces()
    private let PROXIMITY_UUID = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
    
    // Managers/helpers
    private var beaconsManager: BeaconsManager?
    private var speechRecognizerManager: SpeechRecognizerManager?
    private let cache = CacheManager()
    
    // Voice
    var speak: SpeakManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notifications
        NotificationsManager.getAuthorizationStatus { (settings) in
            if settings.authorizationStatus == .notDetermined {
                NotificationsManager.requestAuthorization()
            }
        }
        
        // Talk
        speak = SpeakManager()
        speak?.delegate = self
        
        // Init beacons manager
        beaconsManager = BeaconsManager(uuid: PROXIMITY_UUID, beaconIdentifier: "beacon")
        beaconsManager?.delegate = self
        
        // Speech recognition
        speechRecognizerManager = SpeechRecognizerManager()
        speechRecognizerManager?.delegate = self
        
        // Init background gradient
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 99/255, green: 208/255, blue: 248/255, alpha: 1).cgColor,
            UIColor(red: 50/255, green: 97/255, blue: 231/255, alpha: 1).cgColor
        ]
        
        gradient.frame = self.view.bounds // Set gradient view bounds
        self.view.layer.insertSublayer(gradient, at: 0) // Insert gradient sublayer
        
        self.showTextView.transform = CGAffineTransform(translationX: 0, y: 66)
        
        // Set main label text align
        mainLabel.textAlignment = .center

    }
    
    @IBAction func watsonTouched(_ sender: UIButton) {
        switch watsonState {
        case .talking:
            speak?.avPlayer?.stop()
            setState(.idle, buttonsEnabled: true)
            return
            
        case .thinking:
            self.request?.suspend()
            
            // The player may have allready initiated, stop it
            if let avPlayer = speak?.avPlayer {
                // Check if its playing
                if avPlayer.isPlaying {
                    avPlayer.stop()
                }
            }
            
            setState(.idle, buttonsEnabled: true)
            return
            
        case .idle, .listening:
            do {
                // This will automaticly check if it's allready listening and will stop if so
                try speechRecognizerManager?.startRecording()
            } catch {
                print("Speech recognizer error.\n\(error)")
            }
            
        case .error:
            setState(.idle, buttonsEnabled: true)
            
        }
        
    }
    
    @IBAction func moveTo(_ sender: UIButton) {
        // The tag is like an id defined in the storyboard
        let tag = sender.tag
        delegate?.onMoveTo(viewNumber: tag)
    }
    
    // MARK: Audio player
    
    func didFinishPlaying(succesfully: Bool) {
        // TODO: Missing
        // End talking animation
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10.0, options: .curveEaseInOut, animations: {
            self.showTextView.transform = CGAffineTransform(translationX: 0, y: 66)
        }, completion: nil)
        
        setState(.idle, buttonsEnabled: true)
    }
    
    // Localization state
    func didChangeAuthorization(_ authorized: Bool) {
        // Required to perform in main queue
        OperationQueue.main.addOperation() {
            // Set button isEnabled
            self.nelliButton.isEnabled = authorized
        }
        
    }
    
    func didOutputText(_ text: String?) {
        // Set the text into question
        if (watsonState == .listening) {
            question = text
            mainLabel.text = "\"\(question ?? "")\""
        }
        
    }
    
    func setState(_ state: WatsonState, buttonsEnabled enabled: Bool) {
        watsonState = state
        
        UIView.animate(withDuration: 0.2) {
            self.mapButton.alpha = CGFloat(enabled.hashValue)
            self.discoverButton.alpha = CGFloat(enabled.hashValue)
            self.mapLabel.alpha = CGFloat(enabled.hashValue)
            self.discoverLabel.alpha = CGFloat(enabled.hashValue)
            self.inahImageView.alpha = CGFloat(enabled.hashValue)/2
            self.ibmImageView.alpha = CGFloat(enabled.hashValue)/2
        }
        
        self.mapButton.isEnabled = enabled
        self.discoverButton.isEnabled = enabled
        
        if (enabled) {
            self.question = nil
        }
    }
    
    // MARK: - Transcript
    
    @IBAction func showTranscript(_ sender: UIButton) {
        print("Show transcript")
        performSegue(withIdentifier: "transcriptSegue", sender: self)
    }
    
    // MARK: - Speech
    
    func didEndListening() {
        
        // TODO: Missing
        // Start thinking animation
        mainLabel.text = nil
        
        // Check that we have a question text
        guard question != nil || question != "" else {
            print("No question")
            setState(.idle, buttonsEnabled: true)
            return
        }
        
        // Check that we have a workspaceId
        guard currentWorkspaceId != nil else {
            print("No workspace")
            setState(.idle, buttonsEnabled: true)
            return
        }
        
        mainLabel.text = "Pensando...\n\"\(question ?? "")\""
        watsonState = .thinking
        
        request = Watson.answer(question: question!, workspace: currentWorkspaceId!) { (answer) in
            
            guard let answer = answer else {
                print("Could not get text answer")
                // TODO: Fix
                // It can be fired with a request cancel ._. check fix
                
                self.setState(.error, buttonsEnabled: true)
                return
            }
            
            self.answer = answer
            
            // Check if we have data from caché
            if let dataFromCache = self.cache.getAnswer(answer: answer) {
                // Talk data from caché
                self.speak(data: dataFromCache)
                
                return
            }
            
            // If not make the request
            self.request = Watson.speak(text: answer, workspace: self.currentWorkspaceId!, completion: { (audio) in

                guard let audio = audio else {
                    print("Could not get audio response")
                    // TODO: Fix
                    // It can be fired with a request cancel ._. check fix
                    
                    self.setState(.error, buttonsEnabled: true)
                    return
                }
                
                // Talk response
                self.speak(data: audio)
                
                // Save audio from request
                self.cache.store(answer: answer, data: audio)
            })
            
        }
    }
    
    func speak(data: Data) {
        self.watsonState = .talking
        self.mainLabel.text = "Respondiendo..."
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10.0, options: .curveEaseInOut, animations: {
            self.showTextView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
        self.speak?.play(data: data)
    }
    
    // Speech recognizer availability did change
    func availabilityDidChange(_ available: Bool) {
        nelliButton.isEnabled = available
    }
    
    func didStartListening() {
        // TODO: Missing
        // Listening animation
        mainLabel.text = "Escuchando..."
    
        question = ""
        setState(.listening, buttonsEnabled: false)
    }
    
    // MARK: - Beacons
    
    func didFoundClosestBeacon(_ beacon: CLBeacon?) {
        
        guard let beacon = beacon else {
            // If we dont't have a closet beacon invite to move around and if we dont have a question around
            self.nelliButton.isEnabled = false
            
            if (watsonState == .idle) {
                // Set default background image
                backgroundImage.image = UIImage(named: "Regadera")
                
                // Set label
                setLabelText(text: GO_CLOSER, room: nil, alpha: 1)
            }
            
            return
        }
        
        self.nelliButton.isEnabled = true
        
        let major = beacon.major.intValue
        let minor = beacon.minor.intValue
        if let piece = pieces[major]?[minor] {
            
            // Send notification is we find other piece (beacon)
            if (currentWorkspaceId != piece.workspaceId) {
                
                // Vibrate
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                NotificationsManager.sendNotificationWith(
                    title: NOTIFICATION_TITLE,
                    body: "Estás cerca de la pieza \(piece.title), empieza a preguntar",
                    identifier: "closeToPiece"
                )
                
            }
            
            // Set background image
            backgroundImage.image = UIImage(named: piece.title)
            
            // Set workspaceId
            currentWorkspaceId = piece.workspaceId
            
            // Set label's text and alpha only if it's idle
            if (watsonState == .idle) {
                setLabelText(text: piece.title, room: piece.room.stringValue, alpha: 1)
            }
            
            // Change alpha based on proximity
            switch beacon.proximity {
            case .far:
                setLabelAlpha(0.4) // Indicate that the piece is far
            default: //Near and inmediate and unknown
                setLabelAlpha(1)
                nelliButton.isEnabled = true
            }

        }
    }
    
    // MARK: - UI Changes
    
    func setLabelAlpha(_ alpha: Float) {
        
        UIView.animate(withDuration: 1.0) {
            self.mainLabel.alpha = CGFloat(alpha)
        }
        
    }
    
    func setLabelText(text: String?, room: String?, alpha: Float?) {
        let mainText = NSMutableAttributedString(string: text ?? "", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 34, weight: UIFont.Weight.regular)])
        let room = NSAttributedString(string: room != nil ? "\n\(room!)" : "", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)])
        mainText.append(room)
        
        mainLabel.attributedText = mainText
        
        if let alpha = alpha {
            setLabelAlpha(alpha)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "transcriptSegue":
            let destination = segue.destination as! CaptionsViewController
            destination.answer = answer
            destination.question = question
        default:
            return
        }
    }

}
