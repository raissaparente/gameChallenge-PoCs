//
//  CauldronModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//
import SpriteKit

struct Cauldron {
    let effect: CauldronEffects
    var ingredients: [Ingredient] = []
    
    var isFull: Bool {
        return ingredients.count >= 2
    }
    
    var isCooking: Bool = false
    
    mutating func addIngredient(_ ingredient: Ingredient) {
        self.ingredients.append(ingredient)
    }
}

enum CauldronEffects: Codable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case copper, iron

    var displayText: String {
        switch self {
        case .copper: return "Caldeirão de cobre"
        case .iron: return "Caldeirão de ferro"
        }
    }
    
    var textureName: String {
        switch self {
        case .copper: return "copperCauldron"
        case .iron: return "ironCauldron"
        }
    }
    
    func effect(ingredient: inout Ingredient) {
        if self == .copper {
            print("Inverteu efeito de ingrediente")
            ingredient.toggleActiveEffect()
        } else {}
    }
}


class CauldronSprite: SKSpriteNode {
    var cauldron: Cauldron
    
    init(cauldron: Cauldron) {
        self.cauldron = cauldron
        let texture = SKTexture(imageNamed: cauldron.effect.textureName)
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
