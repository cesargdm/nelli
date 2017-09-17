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
    let minRange: Double
    let information: String

    init (_ title:String, room: Room, workspaceId: String, minRange: Double, info: String) {
        self.title = title
        self.room = room
        self.workspaceId = workspaceId
        self.minRange = minRange
        self.information = info
    }

    static func getPieces() -> [Int:[Piece]] {
        var pieces:[Int:[Piece]] = [Int:[Piece]]()
        pieces[0] = [
            Piece(
                "Friso Estucado",
                room: .mexica,
                workspaceId: "36b526c1-e082-4805-9987-2adfaa82c81c",
                minRange: 6,
                info: "Esta fachada fue recortada y desmontada de un edificio localizado en el sitio Placeres. En 1968 el saqueador pretendió venderla al Museo Metropolitano de Nueva York, pero por fortuna fue rescatada y repatriada a México. La fachada muestra la representación de un mascarón con atributos solares, característica del periodo Clásico temprano y presente en numerosos sitios de la región (como Kohunlich, por mencionar sólo uno). Aparece flanqueado por dioses viejos que sostienen jeroglíficos en ambas manos, aunque el anciano de la derecha sólo conserva el de la mano izquierda."
              ),
            Piece(
                "Piedra del Sol",
                room: .mexica,
                workspaceId: "073ea817-fbef-4051-8f3e-5c4a164a3850",
                minRange: 4.5,
                info: "Monumento colosal con la imagen labrada del disco solar representado como una sucesión de anillos concéntricos con diferentes elementos. En su centro se encuentra el glifo “4 movimiento” (nahui ollin), que rodea el rostro de una deidad solar. El siguiente anillo contiene los 20 signos de los días; alrededor de éste se encuentra otro anillo, labrado con cuadretes que simbolizan los 52 años de un siglo mexica. Dos grandes serpientes de turquesa o xiuhcóatl envuelven todos estos elementos y unen su cabeza en la parte inferior del monolito."
              ),
            Piece(
                "Coatlicue",
                room: .access,
                workspaceId: "43c62df1-4638-4583-b429-83391dd5b703",
                minRange: 4,
                info: "Monumento que sintetiza numerosos significados y asociaciones del pensamiento y la estética de los antiguos mexicanos. Representa a una mujer decapitada y parcialmente desmembrada, con atributos que la relacionan con la tierra, la muerte y con seres sobrenaturales del cielo nocturno. Se ha identificado particularmente con la diosa Coatlicue, madre de Huitzilopochtli, el dios patrono de los mexicas. La escultura fue encontrada en 1790 durante las obras de remodelación de la Plaza Mayor de la capital de la Nueva España."
              ),
            Piece(
                "Penacho de Moctezuma",
                room: .mexica,
                workspaceId: "dcc9709b-8188-4917-bab2-6d11d1f748ed",
                minRange: 6,
                info: "Not Found"
              ),
            Piece(
                "Coyolxauhqui",
                room: .mexica,
                workspaceId: "f9ef9583-9983-4565-9ba3-c049728831a6",
                minRange: 3,
                info: "Cabeza de la diosa Coyolxauhqui (“la que tiene pintura facial de cascabeles”), quien murió en el cerro de Coatepec decapitada y desmembrada por su hermano Huitzilopochtli, el dios patrono de los mexicas. Está ataviada con nariguera y orejeras en forma de rayos de luz. En el cabello lleva un tocado de plumas y pequeños plumones; en sus mejillas se ven los cascabeles de oro que le dan el nombre, y en la base de la escultura, invisible al ojo del visitante, está labrado en bajo relieve el glifo de la guerra."
              ),
            Piece(
                "Ocelocuauhxicalli",
                room: .mexica,
                workspaceId: "d70bc353-b5dd-442c-9fdf-bd29348cea31",
                minRange: 5,
                info: "El jaguar (océlotl) era el señor de la noche y nagual del dios Tezcatlipoca. Sus cualidades de fuerza y peligrosidad lo hicieron el animal tutelar de una importante orden militar. El hueco labrado en el lomo funcionaba como un recipiente sagrado llamado “vaso del águila” (cuauhxicalli); ahí se depositaban la sangre y los corazones de los cautivos sacrificados para alimentar al Sol y a la Tierra. En el contenedor está labrado Huitzilopochtli, dios patrono de los mexicas, y Tezcatlipoca, dios protector de los guerreros."
              )
        ]
        pieces[1] = [
            Piece(
                "Dintel 26",
                room: .maya,
                workspaceId: "0af5181c-cee1-4aa1-9a9d-8afa70f69290",
                minRange: 5,
                info: "Dintel que muestra al gobernante Kokaaj B’ahlam III y a su consorte principal, la Señora K’ab’al Xook. Este dintel formó parte de un conjunto escultórico que se encontraba integrado al Edificio 23 de Yaxchilán. Narra el momento en que el gobernante Kokaaj B’ahlam III, también conocido como Escudo Jaguar III, fue investido con una coraza elaborada con conchas, ante la presencia del numen Huk Chapaaht Tz’ikin K’inich Ajaw. Su consorte, la señora K’ab’al Xook, le entrega un tocado con cabeza de jaguar. Destaca el huipil de la señora, con diseño de ranas en la trama del textil y borde adornado con una banda celeste."
            ),
            Piece(
                "Tumba de Pakal",
                room: .maya,
                workspaceId: "b4e9b2df-1073-44b7-a9f8-9dbe1117588e",
                minRange: 7,
                info: "Not found"
            ),
            Piece(
                "Chac Mool",
                room: .maya,
                workspaceId: "7547a3e5-c402-45a3-abd2-e75c6c8295a5",
                minRange: 3.5,
                info: "Escultura que representa un Chac Mool en su posición característica: recostado con las piernas y brazos flexionados, volteando completamente hacia un lado. Sostiene sobre su vientre una vasija para ofrendas llamada cuauhxicalli, decorada con corazones, plumas y piedras preciosas. Su rostro está cubierto con una variante de la máscara del dios de la lluvia, Tláloc, en la que se distinguen las anteojeras y colmillos. En la parte inferior tiene labrada en bajorrelieve una escena acuática en la que aparece Tláloc en posición agazapada, a manera de Tlaltecuhtli (señor de la tierra)."
            ),
            Piece(
                "Piedra de Tizoc",
                room: .maya,
                workspaceId: "a8be1ed9-06ce-4f83-a3b3-caa844c8652a",
                minRange: 6,
                info: "Cilindro monumental. En la cara superior aparece la imagen labrada del Sol con una oquedad en el centro, de la que se desprende un canal que atraviesa la piedra hasta el borde. El canto de la escultura muestra al gobernante Tízoc, identificado por su glifo onomástico, sujetando por los cabellos a señores de quince distintos pueblos en señal de conquista. Una franja con símbolos estelares limita la parte superior del canto y otra con la imagen del monstruo de la tierra rodea la base del monumento. Este objeto está asociado al sacrificio gladiatorio."
            )
        ]
        pieces[2] = [
            Piece(
                "Mural Dualidad",
                room: .access,
                workspaceId: "348f53b4-2538-4281-ae19-d98e6393ab14",
                minRange: 11,
                info: "Not found"
            )
        ]

        return pieces
    }
}
