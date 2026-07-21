//
//  ARViewContainer.swift
//  MiloTheWarrior
//
//  Created by Luan Aiezza on 21/07/26.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {

    // Estado compartilhado com a HUD
    @ObservedObject var gameState: GameState

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // MARK: - Configuração do ARSession
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]        // Detecta o chão
        config.environmentTexturing = .automatic     // Reflexos

        // LIDAR só ativa se o device suportar
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        // Coordinator cuida da lógica de placement, gestures e updates
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        // Gesture de toque para instanciar
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tap)

        // Cria o reticle (indicador de posição no chão)
        context.coordinator.setupPlacementReticle()

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Reagimos a mudanças de estado da UI aqui, se necessário
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(gameState: gameState)
    }
}
