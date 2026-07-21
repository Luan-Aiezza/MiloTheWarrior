//
//  GameState.swift.swift
//  MiloTheWarrior
//
//  Created by Luan Aiezza on 21/07/26.
//

import RealityKit
import Combine

final class GameState: ObservableObject {
    @Published var isPlaced: Bool = false   // jogo já foi posicionado?
    @Published var canPlace: Bool = false   // há um plano válido no centro?

    // Referência ao personagem
    var character: Entity?
}
