//
//  GameScene2.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 14/04/25.
//

import SpriteKit

struct Ingredient {
    var imageNames: [String]
    var dicedTextureName: String
    var possibleEffects = ["Affection", "Wisdom"]
    var activeEffect: String?
    
    init(imageNames: [String], dicedTextureName: String, possibleEffects: [String] = ["Affection", "Wisdom"], activeEffect: String? = nil) {
        self.imageNames = imageNames
        self.dicedTextureName = dicedTextureName
        self.possibleEffects = possibleEffects
        self.activeEffect = activeEffect
        
        self.chooseEffect(isDiced: false)
    }

    
    mutating func chooseEffect(isDiced: Bool) {
        if isDiced {
            activeEffect = possibleEffects.last
        } else {
            activeEffect = possibleEffects.first
        }
    }
}

class IngredientSprite: SKSpriteNode {
    var ingredient: Ingredient
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        let texture = SKTexture(imageNamed: ingredient.imageNames.first ?? "")
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChopIngredientsScene: SKScene {
    let redIngredient = Ingredient(imageNames: ["red1", "red2", "red3"], dicedTextureName: "redDice")
    let greenIngredient = Ingredient(imageNames: ["green1", "green2", "green3"], dicedTextureName: "greenDice")
    
    var ingredientSprite: IngredientSprite!
    var counter: SKLabelNode!
    
    var currentNumberClicks = 0
    var maxNumberClicks = 20
    var didFinishDicing = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupSprites()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard currentNumberClicks <= maxNumberClicks else {
            return }
        
        currentNumberClicks += 1
        explodingDicedPieces()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if currentNumberClicks >= maxNumberClicks {
            ingredientSprite.ingredient.chooseEffect(isDiced: true)
            counter.text = "Current Effect: \(ingredientSprite.ingredient.activeEffect ?? "")"
            didFinishDicing = true
            ingredientSprite.texture = SKTexture(imageNamed: ingredientSprite.ingredient.imageNames[1])
        } else if currentNumberClicks > 10 {
            ingredientSprite.texture = SKTexture(imageNamed: ingredientSprite.ingredient.imageNames[2])
        }
    }
    
    func explodingDicedPieces() {
        let explosion = SKEmitterNode(fileNamed: "Migalhas")
        explosion?.particleTexture = SKTexture(imageNamed: ingredientSprite.ingredient.dicedTextureName)
        explosion?.zPosition = -1
        explosion?.position = ingredientSprite.position
        
        let explodeAction = SKAction.run {
            self.addChild(explosion!)
        }
        let wait = SKAction.wait(forDuration: 0.5)
        let removeExplosion = SKAction.run {
            explosion?.removeFromParent()
        }
        let explodeSequence = SKAction.sequence([explodeAction, wait, removeExplosion])
        
        self.run(explodeSequence)
    }
    
    func setupSprites() {
        let title = SKLabelNode(text: "Cutting PoC")
        title.fontColor = .white
        title.fontSize = 50
        title.position = CGPoint(x: size.width/2, y: size.height - 50)
        addChild(title)
                
        ingredientSprite = IngredientSprite(ingredient: greenIngredient)
        ingredientSprite.size = CGSize(width: 200, height: 250)
        ingredientSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(ingredientSprite)
        
        counter = SKLabelNode(text: "Current Effect: \(ingredientSprite.ingredient.activeEffect ?? "")")
        counter.fontColor = .white
        counter.fontSize = 40
        counter.position = CGPoint(x: size.width/2, y: size.height - 100)
        addChild(counter)
    }
    
}
