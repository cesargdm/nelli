//
//  SpeechRecognizerManager.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizerManager: NSObject, SFSpeechRecognizerDelegate  {
    
    // Speech recognition variables
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Audio engine
    private let audioEngine = AVAudioEngine()
    
    // Timer
    private var lastString = ""
    private var timer: Timer?
    
    // Custom delegate
    weak var delegate: SpeechRecoginizerDelegate?
    
    override init() {
        super.init()
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                self.delegate?.didChangeAuthorization(true)
            default:
                self.delegate?.didChangeAuthorization(false)
            }
        }
        
    }
    
    // MARK: Speech Recognizer
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        delegate?.availabilityDidChange(available)
    }
    
    
    func startRecording() throws {
        var stoppedListening = false

        // Check if audio is allready running, if it's cancel it
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            // Call stop listening
            stoppedListening = true
            
            //Stops timer
            resetTimer()
        }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()

            self.recognitionTask = nil
        }
        
        // Bug fixing ?
        if let recognitionRequest = recognitionRequest {
            recognitionRequest.endAudio()
        }
        
        // Call if we stopped listening
        if (stoppedListening) {
            delegate?.didEndListening()
            // Stop recording timer
            resetTimer()
            return
        }
        
        // Starting the actual recording
        // Starts timer
        startRecordingTimer()
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        // Fix for strange bug, occured when 
        inputNode.removeTap(onBus: 0)
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Call text results
                self.delegate?.didOutputText(result.bestTranscription.formattedString)
                isFinal = result.isFinal
                self.lastString = result.bestTranscription.formattedString
                self.whileRecordingTimer()
                print(self.lastString)
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                // Call end listening
                if (stoppedListening) {
                    self.delegate?.didEndListening()
                    stoppedListening = true
                }
                
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        // Call start listening
        delegate?.didStartListening()
    }
    
    // MARK: Timer
    
    func startRecordingTimer() {
        lastString = ""
        setTimer(with: 4)
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func whileRecordingTimer() {
        setTimer(with: 2)
    }
    
    func setTimer(with interval:Double) {
        OperationQueue.main.addOperation({[unowned self] in
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { (_) in
                self.timer?.invalidate()
                
                if (self.lastString.characters.count > 0){
                    // Call to stopRecording
                    do {
                        try self.startRecording()
                    } catch {
                        print("START RECORDING ERROR")
                    }
                    
                    self.resetTimer()
                } else {
                    print("Still waiting")
                    /**/
                    self.whileRecordingTimer()
                }
            }
        })
    }
    
}
