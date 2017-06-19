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

class ViewController: UIViewController , SFSpeechRecognizerDelegate{

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textViewSpeech: UITextView!
    
    
    // CONSTANTS
    let COLOR_TOP = UIColor(red: 21/255, green: 129/255, blue: 212/255, alpha: 1)
    let COLOR_BOTTOM = UIColor(red: 0/255, green: 76/255, blue: 136/255, alpha: 1)
    
    // Speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-MX"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Audio
    var voice:Voice?
    
    // Set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init voice class
        voice = Voice()
        
        // Init gradient layer
        let gradient = CAGradientLayer()
        gradient.colors = [COLOR_TOP.cgColor, COLOR_BOTTOM.cgColor] // Assign colors
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
            audioEngine.stop()
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
        
        recognitionRequest.shouldReportPartialResults = false
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if let transcript = result?.bestTranscription.formattedString {
                self.textViewSpeech.text = "\"\(transcript)\""
                
                Watson.textToSpeech(text: transcript, callback: { (data) in
                    if let audioData = data {
                        self.voice?.play(data: audioData)
                    } else {
                        // TODO could not get data
                        print("Didn't get data")
                    }
                    
                })
                
                isFinal = (result?.isFinal)!
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
        
        print("Speech recognizer AVAILABILITY CHANGED")
        
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    
}

