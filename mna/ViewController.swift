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
            Piece("Dintel 26", room: "Sala Maya", workspaceId: "91520396-535c-409c-b1a7-60e2724ec8ba")
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
            startRecording()
            recordButton.isHighlighted = true
        }
    
    }
    
    func startRecording() {
        
        if recognitionTask != nil{
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
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    
    /*
     
     BEACONS
     
     */
    
    func nearBeaconsLocations(_ beacons: [CLBeacon]) {
        if (beacons.count == 0) {
//            self.recordButton.isEnabled = false
        }
        
        pieceTitleLabel.text = pieces[0]?[0].title
        pieceRoomLabel.text = pieces[0]?[0].room.uppercased()
        currentWorkspaceId = pieces[0]?[0].workspaceId
        
        for beacon in beacons {
            let proximity = beacon.proximity
            
            switch proximity {
            case .far:
                UIView.animate(withDuration: 1.0) {
                    self.pieceTitleLabel.alpha = 0.3
                    self.pieceRoomLabel.alpha = 0.3
                }
            case .unknown:
                self.recordButton.isEnabled = false
                
                UIView.animate(withDuration: 1.0) {
                    self.pieceTitleLabel.alpha = 0.1
                    self.pieceRoomLabel.alpha = 0.1
                }
            default: //Near and inmediate
                UIView.animate(withDuration: 1.0) {
                    self.recordButton.isEnabled = true
                    self.pieceTitleLabel.alpha = 1
                    self.pieceRoomLabel.alpha = 1
                }
            }
            
            pieceTitleLabel.text = pieces[0]?[0].title
            pieceRoomLabel.text = pieces[0]?[0].room.uppercased()
            currentWorkspaceId = pieces[0]?[0].workspaceId
        }
    }
    
}

