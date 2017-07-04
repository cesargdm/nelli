//
//  Voice.swift
//  mna
//
//  Created by César Guadarrama, Martín Ruiz, Isaac Secundino on 6/19/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation

class Voice: NSObject, AVAudioPlayerDelegate {
    
    var avPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        
        avPlayer = AVAudioPlayer()
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        print(avPlayer?.isPlaying)
        avPlayer = nil
    }
    
    func play(data: Data) {
        do {
            // AVAudioSessionCategoryPlayAndRecord
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
            avPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeWAVE)
            avPlayer?.delegate = self
            avPlayer?.volume = 1.0
            avPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
