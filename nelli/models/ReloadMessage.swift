//
//  ReloadMessage.swift
//  nelli
//
//  Created by César Guadarrama on 7/28/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation

struct ReloadMessage {
    
    private static let dictionary = [
        "Contactando con Quetzatcoatl",
        "Reconstruyendo a Coyolxauqui",
        "Danza para la lluvia 🌧"
    ]
    
    static func random() -> String {
        let random = arc4random_uniform(UInt32(dictionary.count))
        let message = dictionary[Int(random)]
        
        return message
    }
}
