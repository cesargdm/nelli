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
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
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
            delegate?.didEndListening()
            stoppedListening = true
        }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Call if we stopped listening
        if (stoppedListening) {
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
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
    
}
