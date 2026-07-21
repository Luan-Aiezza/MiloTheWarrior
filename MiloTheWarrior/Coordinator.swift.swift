//
//  Coordinator.swift.swift
//  MiloTheWarrior
//
//  Created by Luan Aiezza on 21/07/26.
//

import RealityKit
import ARKit

final class Coordinator: NSObject, ARSessionDelegate {

    weak var arView: ARView?
    let gameState: GameState

    // Indicador visual de onde o personagem vai ser instanciado
    private var reticle: ModelEntity?
    private var reticleAnchor: AnchorEntity?

    // Guarda o anchor principal do jogo (personagem + cena)
    private var gameAnchor: AnchorEntity?

    init(gameState: GameState) {
        self.gameState = gameState
        super.init()
    }

    // MARK: - Reticle (indicador no chão)

    func setupPlacementReticle() {
        let mesh = MeshResource.generatePlane(width: 0.25, depth: 0.25, cornerRadius: 0.125)
        var material = UnlitMaterial(color: .init(white: 1.0, alpha: 0.6))
        material.color = .init(tint: .white.withAlphaComponent(0.6))

        let disc = ModelEntity(mesh: mesh, materials: [material])
        self.reticle = disc

        let anchor = AnchorEntity()
        anchor.addChild(disc)
        arView?.scene.addAnchor(anchor)
        self.reticleAnchor = anchor
    }

    // MARK: - Atualização por frame (mantém o reticle no chão)

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Se o jogo já foi posicionado, escondemos o reticle
        guard !gameState.isPlaced, let arView = arView else {
            reticle?.isEnabled = false
            return
        }

        // Raycast do centro da tela para o plano horizontal detectado
        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let result = arView.raycast(
            from: center,
            allowing: .estimatedPlane,
            alignment: .horizontal
        ).first else {
            reticle?.isEnabled = false
            gameState.canPlace = false
            return
        }

        // Posiciona o reticle no ponto do raycast
        reticle?.isEnabled = true
        reticleAnchor?.transform.matrix = result.worldTransform
        gameState.canPlace = true
    }

    // MARK: - Toque para instanciar

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard !gameState.isPlaced,
              let arView = arView,
              gameState.canPlace else { return }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let result = arView.raycast(
            from: center,
            allowing: .estimatedPlane,
            alignment: .horizontal
        ).first else { return }

        placeGame(at: result.worldTransform)
    }

    // MARK: - Instanciar Personagem + Cena

    private func placeGame(at worldTransform: simd_float4x4) {
        guard let arView = arView else { return }

        // Anchor fixo no mundo (não segue mais o device)
        let anchor = AnchorEntity(world: worldTransform)
        self.gameAnchor = anchor

        gameState.isPlaced = true          // trava o placement
        reticle?.isEnabled = false

        arView.scene.addAnchor(anchor)

        // Carrega os modelos de forma assíncrona
        Task { @MainActor in
            await loadModels(into: anchor)
        }
    }

    @MainActor
    private func loadModels(into anchor: AnchorEntity) async {
        do {
            // Carrega Cena e Personagem em paralelo com async let
            // AJUSTAR OS NOMES PARA O QUE O GEOVANNE EXPORTAR!!!
            async let sceneEntity = Entity(named: "Scene", in: nil)
            async let characterEntity = Entity(named: "Milo", in: nil)

            // Aguarda os dois terminarem
            let (scene, character) = try await (sceneEntity, characterEntity)

            // Adiciona a cena
            anchor.addChild(scene)

            // Adiciona o personagem
            anchor.addChild(character)
            gameState.character = character

            print("Personagem e cena instanciados!")
        } catch {
            print("Erro ao carregar modelos: \(error.localizedDescription)")
        }
    }

}
