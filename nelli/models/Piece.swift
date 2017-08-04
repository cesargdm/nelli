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
            Piece(
                "Friso Estucado",
                room: .mexica,
                workspaceId: "36b526c1-e082-4805-9987-2adfaa82c81c"
              ),
            Piece(
                "Piedra del Sol",
                room: .mexica,
                workspaceId: "073ea817-fbef-4051-8f3e-5c4a164a3850"
              ),
            Piece(
                "Coatlicue",
                room: .access,
                workspaceId: "43c62df1-4638-4583-b429-83391dd5b703"
              ),
            Piece(
                "Penacho de Moctezuma",
                room: .mexica,
                workspaceId: "dcc9709b-8188-4917-bab2-6d11d1f748ed"
              ),
            Piece(
                "Coyolxauhqui",
                room: .mexica,
                workspaceId: "f9ef9583-9983-4565-9ba3-c049728831a6"
              ),
            Piece(
                "Ocelocuauhxicalli",
                room: .mexica,
                workspaceId: "d70bc353-b5dd-442c-9fdf-bd29348cea31"
              )
        ]
        pieces[1] = [
            Piece(
                "Dintel 26",
                room: .maya,
                workspaceId: "0af5181c-cee1-4aa1-9a9d-8afa70f69290"
            ),
            Piece(
                "Tumba de Pakal",
                room: .maya,
                workspaceId: "536e6b75-98d7-41ae-bbad-4f1d776e56a6"
            ),
            Piece(
                "Chac Mool",
                room: .maya,
                workspaceId: "7547a3e5-c402-45a3-abd2-e75c6c8295a5"
            ),
            Piece(
                "Piedra de Tizoc",
                room: .maya,
                workspaceId: "a8be1ed9-06ce-4f83-a3b3-caa844c8652a"
            )
        ]
        pieces[2] = [
            Piece(
                "Mural Dualidad",
                room: .access,
                workspaceId: "348f53b4-2538-4281-ae19-d98e6393ab14"
            )
        ]

        return pieces
    }
}
