//
//  ViewController.swift
//  mna
//
//  Created by César Guadarrama on 6/16/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController , SFSpeechRecognizerDelegate{

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textViewSpeech: UITextView!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.isEnabled = false
        speechRecognizer?.delegate = self
        
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
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = isButtonEnabled
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func microphoneTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
        }
    
    }
    
    func startRecording(){
        if recognitionTask != nil{
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true,with: .notifyOthersOnDeactivation)
        }catch {
            print("PERRRRRORR audio Session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else{
            fatalError("NO INOUT NODE FATALLLLITY ")
        }
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create sth")
        }
        /////////////////////////////
        
        recognitionRequest.shouldReportPartialResults = true
        
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.textViewSpeech.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                print("error no hay matches")
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
            print("audioEngine couldn't start because of an error.")
        }
        
        textViewSpeech.text = "Say something, I'm listening!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    
}

