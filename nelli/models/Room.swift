//
//  Room.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation

enum Room: Int {
    case mexica = 0, maya = 1, access = 2
    
    var stringValue: String {
        switch self.rawValue {
        case 0:
            return "Sala Mexica"
        case 1:
            return "Sala Maya"
        case 2:
            return "Acceso"
        default:
            return "Sala indefinida"
        }
    }
}