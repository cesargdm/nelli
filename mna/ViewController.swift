//
//  ViewController.swift
//  mna
//
//  Created by César Guadarrama on 6/16/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import UIKit
import Speech
import Alamofire
import AVFoundation

class ViewController: UIViewController , SFSpeechRecognizerDelegate{

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textViewSpeech: UITextView!
    
    
    // CONSTANTS
    let API_HOST = "http://192.168.100.21:8080/v1/text_to_speech"
    let COLOR_TOP = UIColor(red: 21/255, green: 129/255, blue: 212/255, alpha: 1)
    let COLOR_BOTTOM = UIColor(red: 0/255, green: 76/255, blue: 136/255, alpha: 1)
    
    // Speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-MX"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Audio
    private var audioPlayer:AVAudioPlayer?
    var player: AVAudioPlayer?
    
    
    // Set light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init gradient layer
        let gradient = CAGradientLayer()
        gradient.colors = [COLOR_TOP.cgColor, COLOR_BOTTOM.cgColor] // Assign colors
        gradient.frame = self.view.bounds // Asign to view bounds
        
        // Add gradient layer
        self.view.layer.insertSublayer(gradient, at: 0)
        
        // Set record button to disabled until we get mic permissions status
        recordButton.isEnabled = false
        speechRecognizer?.delegate = self
        
        // REquest authorization
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
        
        
        print("HELLO WORLD")
        Alamofire.request("http://www.nch.com.au/acm/11k16bitpcm.wav", method: .get, parameters: ["text":"Texto de prueba"], encoding: URLEncoding.default, headers: nil)
            .responseData { (data) in
                
                print("DATA! 2")
                print(data)
                
//                self.playAudioFromData(data)
                
                if let statusCode = data.response?.statusCode {
                    print("STATUS CODE \(statusCode)")
                }
                print("DATA")
                if let data = data.data {
                    self.play(data: data)
                } else {
                    print("NO DATA DATA")
                }
                
        }
        
        
        
//        playSound()
        
    }
    
    func play(data: Data) {
        do {
            print("PLAYING FROM DATA!")
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeWAVE)
            self.player?.play()
        } catch let error {
            print("ERROR")
            print(error.localizedDescription)
        }
    }
    
//    func playSound() {
//        guard let url = Bundle.main.url(forResource: "response", withExtension: "wav") else {
//            print("Error oppening url")
//
//            return
//        }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            player = try AVAudioPlayer(contentsOf: url)
//
//            guard let player = player else { return }
//
//            player.play()
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
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
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if let transcript = result?.bestTranscription.formattedString {
                self.textViewSpeech.text = "\"\(transcript)\""
                
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
        
        print("SPEECH RECOGNIZER AVAILABILITY CHANGED")
        
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    
}

