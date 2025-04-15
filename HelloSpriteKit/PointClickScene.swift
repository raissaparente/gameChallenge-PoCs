
//
//  GameScene.swift
//  POC-PointAndClick
//
//  Created by Izadora de Oliveira Albuquerque Montenegro on 14/04/25.
//

import SpriteKit
import SwiftUI






class PointClickScene: SKScene {
    
    let ingredients = [
        Ingredient(imageNames: ["red1", "red2", "red3"], dicedTextureName: "redDice", possibleEffects: [.affection, .health]),
        Ingredient(imageNames: ["green1", "green2", "green3"], dicedTextureName: "greenDice", possibleEffects: [.memory, .courage])
    ]
    
    let cauldronsData = [
        Cauldron(effect: .copper),
        Cauldron(effect: .iron)
    ]
    var selectedIngredient: SKSpriteNode? = nil
    
    override func didMove(to view: SKView) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        
        if let ingredient = tappedNode as? IngredientSprite {
            if selectedIngredient == ingredient {
                ingredient.run(SKAction.scale(to: 0.3, duration: 0.1))
                selectedIngredient = nil
            } else {
                selectedIngredient?.run(SKAction.scale(to: 0.2, duration: 0.1))
                selectedIngredient = ingredient
                selectedIngredient?.run(SKAction.scale(to: 0.3, duration: 0.1))
            }
            return
        }
                
        if let selected = selectedIngredient as? IngredientSprite, let cauldron = tappedNode as? CauldronSprite {
            let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
            selected.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
            var ingredientData = selected.ingredient
                    cauldron.cauldron.effect.effect(ingredient: &ingredientData)
            selected.ingredient = ingredientData
            
            selected.run(SKAction.scale(to: 0.2, duration: 0.1))
            selectedIngredient = nil
        } else if let selected = selectedIngredient {
            selected.run(SKAction.scale(to: 0.2, duration: 0.1))
            selectedIngredient = nil
        }
    }

}

//        if (tappedNode.name == "ingredient" || tappedNode.name == "ingredient2" || tappedNode.name == "ingredient3") {
//            if selectedIngredient == tappedNode {
//                selectedIngredient?.run(SKAction.scale(to: 1.0, duration: 0.1))
//                selectedIngredient = nil
//            } else {
//                selectedIngredient?.run(SKAction.scale(to: 1.0, duration: 0.1))
//                selectedIngredient = tappedNode as? SKSpriteNode
//                selectedIngredient?.run(SKAction.scale(to: 1.2, duration: 0.1))
//            }
//            return
//        }

//        let cauldron1 = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 50))
//        cauldron1.name = "Caldeirão 1"
//        cauldron1.position = CGPoint(x: 0, y: 50)
//        addChild(cauldron1)
//
//        let cauldron2 = SKSpriteNode(color: .darkGray, size: CGSize(width: 100, height: 50))
//        cauldron2.name = "Caldeirão 2"
//        cauldron2.position = CGPoint(x: 0, y: 200)
//        addChild(cauldron2)
