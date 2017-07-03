//
//  Piece.swift
//  mna
//
//  Created by César Guadarrama on 6/22/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import Foundation

class Piece {
    let title: String
    let room: Room
    let workspaceId: String
    
    init (_ title:String, room: Room, workspaceId: String) {
        self.title = title
        self.room = room
        self.workspaceId = workspaceId
    }
}
