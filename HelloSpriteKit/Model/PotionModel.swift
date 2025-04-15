//
//  PotionModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//

import SpriteKit

struct Potion {
    var ingredients: [Ingredient]
    var imageName: String = "potion1" //provavelmente vai ser computada a partir da logica de assets
    
    var effects: [IngredientEffect] {
        if let firstEffect = ingredients.first?.activeEffect, let secondEffect = ingredients.last?.activeEffect {
            return [firstEffect, secondEffect]
        } else {
            return []
        }
    }
    
    //COLOCAR SABOR COMO VARIAVEL COMPUTADA AQUI
    
    //COLOCAR LOGICA DE DECISAO DO ASSET
}

class PotionSprite: SKSpriteNode {
    var potion: Potion
    
    init(potion: Potion) {
        self.potion = potion
        
        let texture = SKTexture(imageNamed: "potion1")
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
