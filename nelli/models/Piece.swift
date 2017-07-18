//
//  Piece.swift
//  nelli
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
    
    static func getPieces() -> [Int:[Piece]] {
        var pieces:[Int:[Piece]] = [Int:[Piece]]()
        pieces[0] = [
            Piece("Friso Estucado", room: .mexica, workspaceId: "e2b7f5ad-eb36-4e45-a824-70e1af62e8be"),
            Piece("Piedra del Sol", room: .mexica, workspaceId: "99d3e78d-8e38-448a-903b-d887c5bf3dd3"),
            Piece("Coatlicue", room: .access, workspaceId: "f46bba7b-6355-463a-aaa7-d51386612d50"),
            Piece("Penacho de Moctezuma", room: .mexica, workspaceId: "e151b746-d91c-480c-8137-5cce7294201d"),
            Piece("Coyolxauhqui", room: .mexica, workspaceId: "6c1de7f2-109e-48d6-9418-db2b58b31bde"),
            Piece("Ocelocuauhxicalli", room: .mexica, workspaceId: "1e8f7277-c44c-4933-8ee7-bae318428a73")
        ]
        pieces[1] = [
            Piece("Dintel 26", room: .maya, workspaceId: "1ea9af05-c530-4e56-8c54-eaf95fb13f91"),
            Piece("Tumba de Pakal", room: .maya, workspaceId: "536e6b75-98d7-41ae-bbad-4f1d776e56a6"),
            Piece("Chac Mool", room: .maya, workspaceId: "e1ea6765-3399-4367-85e6-47425605f8b6"),
            Piece("Piedra de Tizoc", room: .maya, workspaceId: "e3fab98f-daaa-47d8-b4b4-dd65775f7f82")
        ]
        pieces[2] = [
            Piece("Mural Dualidad", room: .access, workspaceId: "e2b7f5ad-eb36-4e45-a824-70e1af62e8be")
        ]
        
        return pieces
    }
}
