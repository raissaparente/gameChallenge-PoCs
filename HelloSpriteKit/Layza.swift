//
//  Layza.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//

import SpriteKit

class GameScene: SKScene {
    private var ingredientCopy: SKSpriteNode?
    private var caldron: SKShapeNode!
    private var countIngredients = 0
    
    enum BitMask: UInt32 {
        case mask1 = 1
        case mask2 = 2
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        view.showsFields = true
        
        physicsWorld.gravity = .zero
        
        // Campo gravitacional
        let field = SKFieldNode.radialGravityField()
        field.position = CGPoint(x: frame.midX, y: frame.midY)
        field.region = SKRegion(radius: Float(200))
        field.strength = 6
        field.falloff = 2
        field.categoryBitMask = BitMask.mask1.rawValue
        addChild(field)
        
        // Caldeirão
        let caldronSize: CGFloat = 200
        caldron = SKShapeNode(rectOf: CGSize(width: caldronSize, height: caldronSize), cornerRadius: 100)
        caldron.fillColor = .gray
        caldron.strokeColor = .black
        caldron.alpha = 0.3
        caldron.position = CGPoint(x: frame.midX, y: frame.midY)
        caldron.name = "caldron"
        addChild(caldron)
        
        // Escudo no centro
        let barrierRadius: CGFloat = 10
        let centerBarrier = SKShapeNode(circleOfRadius: barrierRadius)
        centerBarrier.position = caldron.position
        centerBarrier.fillColor = .clear
        centerBarrier.strokeColor = .clear
        centerBarrier.physicsBody = SKPhysicsBody(circleOfRadius: barrierRadius)
        centerBarrier.physicsBody?.isDynamic = false
        centerBarrier.physicsBody?.categoryBitMask = BitMask.mask2.rawValue
        centerBarrier.physicsBody?.contactTestBitMask = BitMask.mask1.rawValue
        centerBarrier.physicsBody?.collisionBitMask = BitMask.mask1.rawValue
        addChild(centerBarrier)
        
        // Botão de limpar
        let clearButton = SKLabelNode(text: "Limpar")
        clearButton.name = "clearButton"
        clearButton.fontSize = 24
        clearButton.fontColor = .black
        clearButton.position = CGPoint(x: frame.midX, y: frame.height - 60)
        addChild(clearButton)
        
        // Ingredientes
        let ingredients: [String] = ["circle", "square", "star", "heart"]
        let spacing: CGFloat = 80
        for (index, ingredientName) in ingredients.enumerated() {
            let sprite = SKSpriteNode(imageNamed: ingredientName)
            sprite.name = "item"
            sprite.size = CGSize(width: 40, height: 40)
            sprite.position = CGPoint(x: frame.width - CGFloat(index + 1) * spacing, y: 100)
            addChild(sprite)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if let node = nodes(at: location).first(where: { $0.name == "clearButton" }) {
            // Remove todas as cópias
            children.filter { $0.name == "copy" }.forEach { $0.removeFromParent() }
            countIngredients = 0
            return
        }
        
        guard countIngredients < 2 else { return } // limita a dois ingredientes selecionados
        
        guard let node = nodes(at: location).first(where: { $0.name == "item" }),
              let shape = node as? SKSpriteNode else { return }
        
        let texture = (node as? SKSpriteNode)?.texture
        let copy = SKSpriteNode(texture: texture)
        copy.size = CGSize(width: 60, height: 60)
        copy.position = location
        copy.name = "copy"
        copy.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.width / 2)
        copy.physicsBody?.affectedByGravity = false
        copy.physicsBody?.fieldBitMask = 0
        copy.physicsBody?.categoryBitMask = BitMask.mask1.rawValue
        copy.physicsBody?.collisionBitMask = BitMask.mask2.rawValue
        addChild(copy)
        
        let scaleUp = SKAction.scale(to: 1.4, duration: 0.2)
        scaleUp.timingMode = .easeOut
        copy.run(scaleUp)
        
        ingredientCopy = copy
        countIngredients += 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self), let node = ingredientCopy else { return }
        node.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = ingredientCopy else { return }
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.width / 2)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = BitMask.mask1.rawValue
        node.physicsBody?.fieldBitMask = BitMask.mask1.rawValue
        node.physicsBody?.linearDamping = 1.5
        
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.2)
        scaleBack.timingMode = .easeIn
        node.run(scaleBack)
        
        ingredientCopy = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children where node.name == "copy" {
            guard let body = node.physicsBody else { continue }
            
            let dx = caldron.position.x - node.position.x
            let dy = caldron.position.y - node.position.y
            let distance = hypot(dx, dy)
            
            if distance > 300 {
                node.removeFromParent()
                countIngredients -= 1
                continue
            }
            
            if distance < 20 {
                body.velocity.dx *= 0.9
                body.velocity.dy *= 0.9
                body.fieldBitMask = 0
                
                node.position.x += dx * 0.1
                node.position.y += dy * 0.1
                
                if distance < 1 {
                    body.velocity = .zero
                    body.angularVelocity = 0
                    body.isDynamic = false
                    node.position = caldron.position
                }
            }
        }
    }
}
