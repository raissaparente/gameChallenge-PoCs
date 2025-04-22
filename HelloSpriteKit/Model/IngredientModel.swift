//
//  IngredientModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//

import SpriteKit

struct Ingredient {
    var name: String
    var imageNames: [String]
    var dicedTextureName: String
    var possibleEffects: [IngredientEffect]
    var activeEffect: IngredientEffect?
    var flavor: Flavor
    
    init(name: String, imageNames: [String], dicedTextureName: String, possibleEffects: [IngredientEffect], activeEffect: IngredientEffect? = nil, flavor: Flavor) {
        self.name = name
        self.imageNames = imageNames
        self.dicedTextureName = dicedTextureName
        self.possibleEffects = possibleEffects
        self.activeEffect = activeEffect
        self.flavor = flavor
        
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

enum IngredientState {
    case idle, inChoppingBlock, chopped, inCauldron, cooking
}


class IngredientSprite: SKSpriteNode {
    var ingredient: Ingredient
    var state: IngredientState
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        self.state = .idle
        
        let texture = SKTexture(imageNamed: ingredient.imageNames.first ?? "")
        super.init(texture: texture, color: .clear, size: texture.size())
        name = ingredient.imageNames.first
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChoppingBlockSprite: SKSpriteNode {
    
}
