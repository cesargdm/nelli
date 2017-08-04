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
        "Reconstruyendo a la Coyolxauqui",
        "Danza para la lluvia 💃🌧",
        "Enviando mensaje a Quetzatcoatl 🐍",
        "Conectando con el supramundo...",
        "Gracias a César, Martín e Isaac 👨🏽‍💻",
        "🕳 Abriendo un portal con la historia...",
        "🚢 Navegando sobre un mar de cultura...",
        "👁🐝M"
    ]
    
    static func random() -> String {
        let random = arc4random_uniform(UInt32(dictionary.count))
        let message = dictionary[Int(random)]
        
        return message
    }
}
