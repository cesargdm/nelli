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
    fileprivate var lastString = ""

    //Test
    //private var timer = Timer()
    fileprivate var timer:Timer?
    func startRecordingTimer() {
        lastString = ""
        createTimerTimer(4)
    }
    func stopRecordingTimer() {
        timer?.invalidate()
        timer = nil
    }
    fileprivate func whileRecordingTimer() {
        createTimerTimer(2)
    }
    func createTimerTimer(_ interval:Double) {
        OperationQueue.main.addOperation({[unowned self] in
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { (_) in
                self.timer?.invalidate()
                if(self.lastString.characters.count > 0){
                    //DO SOMETHING
                    print("End listening!")
                    do{
                        try self.startRecording()
                    }catch{
                        
                    }
                    self.stopRecordingTimer()
                    
                    
                }else{
                    print("Still waiting")
                    /**/
                    self.whileRecordingTimer()
                    
                }
            }
        })
    }
    
    //End Test
    

    
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
    
    func stopRecording(){
        print("StopRecording!")
        if audioEngine.isRunning{
            audioEngine.stop()
            
            recognitionRequest?.endAudio()
            
            // Call stop listening
            stoppedListening = true
        }
        
        
        // Call if we stopped listening
        if (stoppedListening) {
            delegate?.didEndListening()
            return
        }
    }
    //variable stoppedListening in no longer local
    var stoppedListening = false

    func startRecording() throws {

        // Check if audio is allready running, if it's cancel it
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            // Call stop listening
            stoppedListening = true
            
            //Stops timer
            stopRecordingTimer()
        }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()

            self.recognitionTask = nil
        }
        
        // Bug fixing
        if let recognitionRequest = recognitionRequest {
            recognitionRequest.endAudio()
        }
        
        // Call if we stopped listening
        if (stoppedListening) {
            delegate?.didEndListening()
            // Stop recording timer
            stopRecordingTimer()
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
                if (self.stoppedListening) {
                    self.delegate?.didEndListening()
                    self.stoppedListening = true
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
