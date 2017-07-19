//
//  Voice.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import AVFoundation

protocol TalkDelegate: class {
    func didFinishPlaying(succesfully: Bool)
}

class Talk: NSObject, AVAudioPlayerDelegate {
    
    var avPlayer: AVAudioPlayer?
    weak var delegate: TalkDelegate?
    
    override init() {
        super.init()
    }
    
    func stop() {
        avPlayer?.stop()
        avPlayer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Stop player
        player.stop()
        avPlayer = nil
        
        // Call delegate
        delegate?.didFinishPlaying(succesfully: flag)
    }
    
    func play(data: Data) {
        do {
            // AVAudioSessionCategoryPlayAndRecord
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            avPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            avPlayer?.delegate = self
            avPlayer?.volume = 1.0
            avPlayer?.play()
            
        } catch let error {
            print(" AVAudio Player error \(error.localizedDescription)")
        }
    }
    
}
