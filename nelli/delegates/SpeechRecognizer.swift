//
//  SpeechRecognizer.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation

protocol SpeechRecoginizerDelegate: class {
    func didChangeAuthorization(_ authorized: Bool)
    func didOutputText(_ text: String?)
    func availabilityDidChange(_ available: Bool)
    func didEndListening()
    func didStartListening()
}
