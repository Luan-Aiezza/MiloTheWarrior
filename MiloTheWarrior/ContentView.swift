//
//  ContentView.swift
//  MiloTheWarrior
//
//  Created by Luan Aiezza on 06/07/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        ZStack {
            ARViewContainer(gameState: gameState)
                .edgesIgnoringSafeArea(.all)

            // HUD simples para instrução
            if !gameState.isPlaced {
                VStack {
                    Spacer()
                    Text(gameState.canPlace
                         ? "Toque para posicionar Milo"
                         : "Aponte para o chão para encontrar uma superfície")
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
