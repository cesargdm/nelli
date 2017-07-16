//
//  ViewController.swift
//  mna
//
//  Created by César Guadarrama, Martín Ruiz, Isaac Secundino on 6/19/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit
import Speech
import Alamofire
import AVFoundation
import CoreLocation
import UserNotifications

class ViewController: UIViewController, BeaconDelegate, SpeechRecoginizerDelegate, TalkDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textViewSpeech: UITextView!
    @IBOutlet weak var pieceTitleLabel: UILabel!
    @IBOutlet weak var pieceRoomLabel: UILabel!
    
    // Question text
    private var question: String?
    private var currentWorkspaceId: String?
    private var currentBeacon: CLBeacon?
    
    // Pieces variable declaration
    private var pieces:[Int:[Piece]] = [Int:[Piece]]()

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
        
        //Init pieces data
        initializePieces()
        
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
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
        do {
            try speechRecognizerManager?.startRecording()
        } catch {
            print("ERROR \(error)")
        }
    }
    
    //
    // MARK: Talk
    //
    
    func didFinishPlaying(succesfully: Bool) {
        self.textViewSpeech.text = ""
    }
    
    //
    // MARK: Speech Recognizer
    //
    
    func didChangeAuthorization(_ authorized: Bool) {
        
        print("Did change auth")
        // Change the enabling based on authorization
        OperationQueue.main.addOperation() {
            self.recordButton.isEnabled = authorized
        }
        
    }
    
    func didOutputText(_ text: String?) {
        // Set the output text to label
        print("DID OUTPUT TEXT")
        textViewSpeech.text = "\"\(text ?? "")\""
        question = text
    }
    
    func availabilityDidChange(_ available: Bool) {
        self.recordButton.isEnabled = available
    }
    
    func didEndListening() {
        
        print("END LISTENING")
        if let _ = self.textViewSpeech.text {
            self.textViewSpeech.text = "Pensando...\n(\(self.textViewSpeech.text))"
        }
        
        self.recordButton.isEnabled = true
        
        if let question = question {
            if let workspaceId = self.currentWorkspaceId {
                
                Watson.textToSpeech(text: question, workspaceId: workspaceId, callback: { (data) in
                    if let audioData = data {
                        self.textViewSpeech.text = "Respondiendo..."
                        self.talk?.play(data: audioData)
                    } else {
                        // TODO could not get data
                        print("Didn't get data")
                    }
                })
            } else {
                print("NO WORKSPACE ID")
            }
        } else {
            print("NO TEXT")
        }
        
    }
    
    func didStartListening() {
        self.textViewSpeech.text = "Escuchando..."
    }
    
    // Set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // If speech recognizer is available set the button to enable or disabled
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    //
    // MARK: Label's UI Changes
    //
    
    func setLabelsAlpha(_ alpha: Float) {
        UIView.animate(withDuration: 1.0) {
            self.pieceTitleLabel.alpha = CGFloat(alpha)
            self.pieceRoomLabel.alpha = CGFloat(alpha)
        }
    }
    
    func setLabelsText(title: String?, room: String?, alpha: Float?) {
        pieceTitleLabel.text = title
        pieceRoomLabel.text = room
        if alpha != nil {
            setLabelsAlpha(alpha!)
        }
    }
    
    // MARK: Beacons
    
    func didFoundClosestBeacon(_ beacon: CLBeacon?) {
        
//        print("Found closest beacon...")
        
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
                setLabelsText(title: piece.title, room: piece.room.stringValue, alpha: 1)
                
                // Change alpha based on proximity
                switch beacon!.proximity {
                case .far:
                    self.setLabelsAlpha(0.4) // Indicate that the piece is far
                case .unknown:
                    self.setLabelsAlpha(0.2) // Disable the button since it's in a unstable distance
                    self.recordButton.isEnabled = false
                default: //Near and inmediate
                    self.setLabelsAlpha(1)
                    self.recordButton.isEnabled = true
                }
            }
        } else {
            // If we dont't have a closet beacon invite to move around
            setLabelsText(title: "Acércate a una pieza", room: nil, alpha: 0.7)
        }
        
    }
    
    // MARK: Pieces Initalization
    
    func initializePieces() {
        pieces[0] = [
            Piece("Friso Estucado", room: .mexica, workspaceId: "e2b7f5ad-eb36-4e45-a824-70e1af62e8be"),
            Piece("Piedra del Sol", room: .mexica, workspaceId: "99d3e78d-8e38-448a-903b-d887c5bf3dd3"),
            Piece("Coatlicue", room: .access, workspaceId: "f46bba7b-6355-463a-aaa7-d51386612d50"),
            Piece("Penacho de Moctezuma", room: .mexica, workspaceId: "e151b746-d91c-480c-8137-5cce7294201d"),
            Piece("Coyolxauhqui", room: .mexica, workspaceId: "6c1de7f2-109e-48d6-9418-db2b58b31bde"),
            Piece("Ocelocuauhxicalli", room: .mexica, workspaceId: "1e8f7277-c44c-4933-8ee7-bae318428a73")
        ]
        pieces[1] = [
            Piece("Dintel 26", room: .maya, workspaceId: "1ea9af05-c530-4e56-8c54-eaf95fb13f91"),
            Piece("Tumba de Pakal", room: .maya, workspaceId: "536e6b75-98d7-41ae-bbad-4f1d776e56a6"),
            Piece("Chac Mool", room: .maya, workspaceId: "e1ea6765-3399-4367-85e6-47425605f8b6"),
            Piece("Piedra de Tizoc", room: .maya, workspaceId: "e3fab98f-daaa-47d8-b4b4-dd65775f7f82")
        ]
        pieces[2] = [
            Piece("Mural Dualidad", room: .access, workspaceId: "e2b7f5ad-eb36-4e45-a824-70e1af62e8be")
        ]
    }
    
}

