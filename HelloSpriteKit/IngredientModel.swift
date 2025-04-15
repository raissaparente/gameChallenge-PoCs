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
    var possibleEffects: [IngredientsEffects]
    var activeEffect: IngredientsEffects?
    
    init(imageNames: [String], dicedTextureName: String, possibleEffects: [IngredientsEffects], activeEffect: IngredientsEffects? = nil) {
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
    
    mutating func toggleActiveEffect() {
        switch activeEffect {
        case .memory:
            activeEffect = .Nomemory
        case .health:
            activeEffect = .Nohealth
        case .courage:
            activeEffect = .Nocourage
        case .affection:
            activeEffect = .Noaffection
        case .wisdom:
            activeEffect = .Nowisdom
        case .Nomemory:
            activeEffect = .memory
        case .Nohealth:
            activeEffect = .health
        case .Nocourage:
            activeEffect = .courage
        case .Noaffection:
            activeEffect = .affection
        case .Nowisdom:
            activeEffect = .wisdom
        case .none:
            activeEffect = nil
        }
    }
    
}

enum IngredientsEffects: Codable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case memory, health, courage, affection, wisdom, Nomemory, Nohealth, Nocourage, Noaffection, Nowisdom
    
    var effectText: String {
        switch self {
        case .memory: return "Aumenta sua memória"
        case .health: return "Aumenta sua saúde"
        case .courage: return "Aumenta sua coragem"
        case .affection: return "Aumenta seu afeto"
        case .wisdom: return "Aumenta sua sabedoria"
        case .Nomemory: return "Diminui sua memória"
        case .Nohealth: return "Diminui sua saúde"
        case .Nocourage: return "Diminui sua coragem"
        case .Noaffection: return "Diminui seu afeto"
        case .Nowisdom: return "Diminui sua sabedoria"
        }
    }
    
    // fiquei com preguica de fazer tudo
    var textureName: String {
        switch self {
        case .memory: return "memoryImage"
        case .health: return "healthImage"
        default: return "ingredientImage"
        }
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
