//
//  AudioSpeaker.swift
//  PinacoApp
//
//  Created by Marco Aurélio Bigélli Cardoso on 07/04/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation

// AVAudioPlayer wrapper
class AudioSpeaker: NSObject, AVAudioPlayerDelegate {
    weak var delegate: AudioSpeakerDelegate?
    var player: AVAudioPlayer?
    
    func play(audio: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: audio, fileTypeHint: AVFileTypeWAVE)
            player?.delegate = self
            player?.prepareToPlay()
            delegate?.didStartSpeaking()
            player?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func cancel() {
        player?.stop()
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didStopSpeaking()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("[x] Audio Player Decode Error: \(error?.localizedDescription)")
    }
    
}

protocol AudioSpeakerDelegate: class {
    func didStartSpeaking()
    func didStopSpeaking()
}
