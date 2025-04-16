//
//  IngredientModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//

import SpriteKit

struct Ingredient {
    var imageNames: [String]
    var dicedTextureName: String
    var possibleEffects: [IngredientEffect]
    var activeEffect: IngredientEffect?
    
    init(imageNames: [String], dicedTextureName: String, possibleEffects: [IngredientEffect], activeEffect: IngredientEffect? = nil) {
        self.imageNames = imageNames
        self.dicedTextureName = dicedTextureName
        self.possibleEffects = possibleEffects
        self.activeEffect = activeEffect
        
        self.chooseEffect(isDiced: false)
    }
    
    //quando picar
    mutating func chooseEffect(isDiced: Bool) {
        activeEffect = isDiced ? possibleEffects.last : possibleEffects.first
    }
    
    //quando mudar o caldeirao
    mutating func toggleActiveEffect() {
        activeEffect?.toggle()
    }
}

enum EffectType: String, Codable, CaseIterable, Identifiable {
    case memory, health, courage, affection, wisdom
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .memory: return "memória"
        case .health: return "saúde"
        case .courage: return "coragem"
        case .affection: return "afeto"
        case .wisdom: return "sabedoria"
        }
    }
}

struct IngredientEffect: Codable, Identifiable {
    let type: EffectType
    var isPositive: Bool
    
    var id: String { "\(type.rawValue)-\(isPositive)" }
    
    var points: Int {
        isPositive ? 1 : -1
    }
    
    var effectText: String {
        let verb = isPositive ? "Aumenta" : "Diminui"
        return "\(verb) sua \(type.description)"
    }
    
    mutating func toggle() {
        isPositive.toggle()
    }
}

enum IngredientState {
    case idle, choppingBlock, chopped, inCauldron, cooking
}


class IngredientSprite: SKSpriteNode {
    var ingredient: Ingredient
    var state: IngredientState
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        self.state = .idle
        
        let texture = SKTexture(imageNamed: ingredient.imageNames.first ?? "")
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChoppingBlockSprite: SKSpriteNode {
    
}
