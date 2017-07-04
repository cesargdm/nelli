//
//  SpeechManager.swift
//  mna
//
//  Created by César Guadarrama on 6/21/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import Foundation
import Speech

protocol SpeechRecoginizerDelegate: class {
    func didChangeAuthorization(_ authorized: Bool)
    func didOutputText(_ text: String?)
    func availabilityDidChange(_ available: Bool)
    func didEndOutputText()
    func didStartListening()
}

class SpeechRecognizerManager: NSObject, SFSpeechRecognizerDelegate  {
    
    var audioEngine: AVAudioEngine?
    var request: SFSpeechAudioBufferRecognitionRequest?
    var recognizer: SFSpeechRecognizer?
    
    weak var delegate: SpeechRecoginizerDelegate?
    
    override init() {
        super.init()
        
        audioEngine = AVAudioEngine()
        
        SFSpeechRecognizer.requestAuthorization { status in
            print("SPEECH STATUS: \(status.rawValue)")
            switch status {
            case .authorized:
                self.delegate?.didChangeAuthorization(true)
            default:
                self.delegate?.didChangeAuthorization(false)
            }
        }
        
        // Record audio
        request = SFSpeechAudioBufferRecognitionRequest()
        
        guard let node = audioEngine?.inputNode else {
            print("COULD NOT SET NODE")
            return
        }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request?.append(buffer)
        }
        
        // Speech recognizer
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
        
        if recognizer?.isAvailable == false {
            print("RECOGNIZER IS NOT AVAILABLE")
            // The recognizer is not available right now
            return
        }
        
    }
    
    func startRecordingSpeech() {
        
        if (request == nil) {
            print("Request not initialized")
            return
        }
        
        // Stop 
        request?.endAudio()
        audioEngine?.stop()
        
        
        audioEngine?.prepare()
        do {
            try audioEngine?.start()
        } catch {
            print("AUDIO ENGINE ERROR \(error)")
        }
        
        request?.shouldReportPartialResults = true
        
        recognizer?.recognitionTask(with: request!) { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                
                self.delegate?.didOutputText(bestString)
                
                if result.isFinal {
                    // Print the speech that has been recognized so far
                    self.delegate?.didEndOutputText()
                    print("FINAL: \(result.bestTranscription.formattedString)")
                }
            } else {
                print("ERROR")
            }
            
        }
    }
    
}
