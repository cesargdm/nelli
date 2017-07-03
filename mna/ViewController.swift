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

enum Room: Int {
    case mexica = 0, maya = 1, access = 2
    
    var stringValue: String {
        switch self.rawValue {
        case 0:
            return "Sala Mexica"
        case 1:
            return "Sala Maya"
        case 2:
            return "Acceso"
        default:
            return "Sala indefinida"
        }
    }
}

class ViewController: UIViewController , SFSpeechRecognizerDelegate, BeaconDelegate {
    
    var pieces:[Int:[Piece]] = [Int:[Piece]]()

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textViewSpeech: UITextView!
    @IBOutlet weak var pieceTitleLabel: UILabel!
    @IBOutlet weak var pieceRoomLabel: UILabel!

    // CONSTANTS
    let COLOR_TOP = UIColor(red: 0/255, green: 158/255, blue: 255/255, alpha: 1)
    let COLOR_BOTTOM = UIColor(red: 0/255, green: 42/255, blue: 69/255, alpha: 1)
    
    let PROXIMITY_UUID = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
    let BEACON_IDENTIFIER = "MyBeacon"
    
    var currentWorkspaceId: String?
    
    // Speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-MX"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Beacons
    private var beaconsManager: BeaconsManager?
    
    // Audio
    var voice:Voice?
    
    // Set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init data
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
        
        //Init voice class
        voice = Voice()
        
        //Init beacons manager
        beaconsManager = BeaconsManager(uuid: PROXIMITY_UUID, beaconIdentifier: "beacon")
        beaconsManager?.delegate = self
        
        // Init gradient layer
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 18/255, green: 139/255, blue: 219/255, alpha: 1).cgColor,
            UIColor(red: 20/255, green: 155/255, blue: 245/255, alpha: 1).cgColor,
            UIColor(red: 20/255, green: 155/255, blue: 245/255, alpha: 1).cgColor,
            UIColor(red: 15/255, green: 115/255, blue: 181/255, alpha: 1).cgColor
        ] // Assign colors
        gradient.frame = self.view.bounds // Asign to view bounds
        
        // Add gradient layer
        self.view.layer.insertSublayer(gradient, at: 0)
        
        // Set record button to disabled until we get mic permissions status
        recordButton.isEnabled = false
        speechRecognizer?.delegate = self
        
        // Request authorization
        SFSpeechRecognizer.requestAuthorization{
            (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus{
                case .authorized:
                    isButtonEnabled = true
                case .denied:
                    isButtonEnabled = false
                    print("User denied access to speech recognition")
                case .restricted:
                    isButtonEnabled = false
                    print("Restricted")
                case .notDetermined:
                    isButtonEnabled = false
                    print("Not yet auth")
            }
            
            // Set the button to its propper enable state
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = isButtonEnabled
            }
            
        }
        
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
        if audioEngine.isRunning {
            recordButton.isHighlighted = false
            audioEngine.stop() // Stop audio
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
        } else {
            print("Recording...")
            audioEngine.stop()
            startRecording()
            recordButton.isHighlighted = true
        }
    
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("Error in audio session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine input note error")
        }

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create recognition request")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if let transcript = result?.bestTranscription.formattedString {
                self.textViewSpeech.text = "\"\(transcript)\""
                
                isFinal = (result?.isFinal)!
                
                if (isFinal && self.currentWorkspaceId != nil) {
                    Watson.textToSpeech(text: transcript, workspaceId: self.currentWorkspaceId!, callback: { (data) in
                        if let audioData = data {
                            print("Playing data...")
                            self.voice?.play(data: audioData)
                        } else {
                            // TODO could not get data
                            print("Didn't get data")
                        }
                        
                    })
                } else {
                    print("No workspace selected")
                }
                
            }
            
            if (error != nil || isFinal) {
                
                if (error != nil) {
                    self.textViewSpeech.text = "Intentalo de nuevo"
                }
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine couldn't start because of an error")
        }
        
        textViewSpeech.text = "Escuchando..."
    }
    
    // If speech recognizer is available set the button to enable or disabled
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    // MARK: Label's UI Changes
    
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
        if (beacon != nil) {
            if let piece = pieces[Int(beacon!.major)]?[Int(beacon!.minor)] {
                
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
    
}

