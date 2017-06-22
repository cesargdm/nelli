//
//  Voice.swift
//  mna
//
//  Created by César Guadarrama, Martín Ruiz, Isaac Secundino on 6/19/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation

class Voice {
    var player: AVAudioPlayer?
    
    init() {
        player = AVAudioPlayer()
    }
    
    func play(data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeWAVE)
            player?.volume = 1.0
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
