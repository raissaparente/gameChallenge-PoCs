//
//  UnifiedScene.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//
import SpriteKit

class UnifiedScene: SKScene {
    let ingredients = [
        Ingredient(imageNames: ["red1", "red2", "red3"], dicedTextureName: "redDice", possibleEffects: [.affection, .health]),
        Ingredient(imageNames: ["green1", "green2", "green3"], dicedTextureName: "greenDice", possibleEffects: [.memory, .courage]),
        Ingredient(imageNames: ["c1", "c2", "c3"], dicedTextureName: "dices", possibleEffects: [.wisdom, .affection])
    ]
    
    let cauldronsData = [
        Cauldron(effect: .copper),
        Cauldron(effect: .iron)
    ]
    
    var selectedIngredient: IngredientSprite? = nil
    
    
    //MARK: CHOPPING ACTION
    var block: ChoppingBlockSprite!
    var counter: SKLabelNode!
    var currentNumberClicks = 0
    var maxNumberClicks = 20
    var didFinishDicing = false
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupIngredients()
        setupCauldrons()
        setupBlock()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        clickToChopIngredient()
        moveIngredientToClickedDestination(touches: touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateChopIngredient()
    }
    
    func setupIngredients() {
        let spacing: CGFloat = 100
        let centerY = size.height / 2
        let xPosition = size.width * 0.8
        
        for (index, data) in ingredients.enumerated() {
            let ingredient = IngredientSprite(ingredient: data)
            let offset = CGFloat(index - (ingredients.count - 1) / 2) * spacing
            ingredient.position = CGPoint(x: xPosition, y: centerY + offset)
            ingredient.setScale(0.09)
            addChild(ingredient)
        }
    }
    
    func setupCauldrons() {
        let spacing: CGFloat = 200
        let xPosition = size.width * 0.2
        let yPosition = size.height * 0.2
        
        for (index, data) in cauldronsData.enumerated() {
            let cauldron = CauldronSprite(cauldron: data)
            let offset = CGFloat(index - (cauldronsData.count - 1) / 2) * spacing
            cauldron.position = CGPoint(x: xPosition + offset, y: yPosition)
            cauldron.setScale(0.25)
            addChild(cauldron)
        }
    }
    
    func setupBlock() {
        block = ChoppingBlockSprite(imageNamed: "block")
        block.size = CGSize(width: 350, height: 150)
        block.position = CGPoint(x: size.width * 0.2, y: size.height * 0.75)
        block.zPosition = -5
        addChild(block)
    }
    
    func moveIngredientToClickedDestination(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        //select ingredient
        if let ingredient = tappedNode as? IngredientSprite {
            
            guard ingredient.state == .idle || ingredient.state == .chopped else { return }
            
            print("clicou no ingrediente")
            
            if selectedIngredient == ingredient {
                ingredient.run(SKAction.scale(to: 0.2, duration: 0.1))
                selectedIngredient = nil
            } else {
                selectedIngredient?.run(SKAction.scale(to: 0.1, duration: 0.1))
                selectedIngredient = ingredient
                selectedIngredient?.run(SKAction.scale(to: 0.2, duration: 0.1))
            }
            return
        }
        
        //take ingredient to cauldron
        if let selected = selectedIngredient as? IngredientSprite, let cauldronSprite = tappedNode as? CauldronSprite {
            print("clicou no caldeirao")
            
            let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
            selected.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
            
            var ingredientData = selected.ingredient
            cauldronSprite.cauldron.effect.effect(ingredient: &ingredientData)
            
            selected.run(SKAction.scale(to: 0.2, duration: 0.1))
            
            //add ingredient to cauldron
            cauldronSprite.cauldron.addIngredient(ingredientData)
            selectedIngredient = nil
            
            
            // take ingredient to chopping block
        } else if let selected = selectedIngredient as? IngredientSprite, let block = tappedNode as? ChoppingBlockSprite {
            print("clicou no bloco")
            
            let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
            selected.run(moveAction)
            
            selectedIngredient?.state = .choppingBlock
            
        } else if let selected = selectedIngredient {
            selected.run(SKAction.scale(to: 0.2, duration: 0.1))
            selectedIngredient = nil
        }
    }
    
    func updateChopIngredient() {
        guard let ingredientSprite = selectedIngredient else { return }
        guard ingredientSprite.state == .choppingBlock else { return }
        
        if currentNumberClicks > maxNumberClicks {
            ingredientSprite.ingredient.chooseEffect(isDiced: true)
            didFinishDicing = true
        } else if currentNumberClicks > maxNumberClicks-1 {
            ingredientSprite.texture = SKTexture(imageNamed: ingredientSprite.ingredient.imageNames[2])
        } else if currentNumberClicks > 10 {
            ingredientSprite.texture = SKTexture(imageNamed: ingredientSprite.ingredient.imageNames[1])
        }
    }
    
    func clickToChopIngredient() {
        guard let ingredientSprite = selectedIngredient else { return }
        guard ingredientSprite.state == .choppingBlock else { return }
        guard currentNumberClicks < maxNumberClicks else { return }
        
        currentNumberClicks += 1
        explodingDicedPieces()
        
        print("COUNTER: \(currentNumberClicks)")
    }
    
    
    func explodingDicedPieces() {
        guard let ingredientSprite = selectedIngredient else { return }
        guard ingredientSprite.state == .choppingBlock else { return }
        
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
}
