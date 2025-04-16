//
//  UnifiedScene.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 15/04/25.
//
import SpriteKit


class UnifiedScene: SKScene {
    let ingredients = [
        Ingredient(imageNames: ["red1", "red2", "red3"], dicedTextureName: "redDice", possibleEffects: [IngredientEffect(type: .affection, isPositive: true), IngredientEffect(type: .health, isPositive: true)]),
        Ingredient(imageNames: ["green1", "green2", "green3"], dicedTextureName: "greenDice", possibleEffects: [IngredientEffect(type: .memory, isPositive: true), IngredientEffect(type: .wisdom, isPositive: false)]),
        Ingredient(imageNames: ["c1", "c2", "c3"], dicedTextureName: "dices", possibleEffects: [IngredientEffect(type: .health, isPositive: true), IngredientEffect(type: .memory, isPositive: false)])
    ]
    
    let cauldronsData = [
        Cauldron(effect: .copper),
        Cauldron(effect: .iron)
    ]
    
    var selectedCauldronIndex = 0
   var selectedCauldronSprite: CauldronSprite!
    var potionSprite: PotionSprite!
    
    var selectedIngredient: IngredientSprite? = nil
    let ingredientScaleNormal: CGFloat = 0.09
    let ingredientScaleSelected: CGFloat = 0.12
    
    //MARK: CHOPPING ACTION
    var block: ChoppingBlockSprite!
    var counter: SKLabelNode!
    var currentNumberClicks = 0
    var maxNumberClicks = 20
    var didFinishDicing = false
    
    
    var statusLabel: SKLabelNode!
    
    var sandboxArea: SandboxArea!

    
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
        setupSwitchButton()
        setupStatusLabel()
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
        let xPosition = size.width * 0.9
        
        for (index, data) in ingredients.enumerated() {
            let ingredient = IngredientSprite(ingredient: data)
            let offset = CGFloat(index - (ingredients.count - 1) / 2) * spacing
            ingredient.position = CGPoint(x: xPosition, y: centerY + offset)
            ingredient.setScale(ingredientScaleNormal)
            addChild(ingredient)
        }
    }
    
    func setupCauldrons() {
        let xPosition = size.width * 0.3
        let yPosition = size.height * 0.2

        let cauldron = CauldronSprite(cauldron: cauldronsData[selectedCauldronIndex])
        cauldron.position = CGPoint(x: xPosition, y: yPosition)
        cauldron.setScale(0.25)

        selectedCauldronSprite = cauldron
        addChild(cauldron)
    }

    func switchCauldron() {
        // remove current cauldron
        selectedCauldronSprite.removeFromParent()

        // update index
        selectedCauldronIndex = (selectedCauldronIndex + 1) % cauldronsData.count

        // add new cauldron
        let xPosition = size.width * 0.3
        let yPosition = size.height * 0.2

        let newCauldron = CauldronSprite(cauldron: cauldronsData[selectedCauldronIndex])
        newCauldron.position = CGPoint(x: xPosition, y: yPosition)
        newCauldron.setScale(0.25)

        selectedCauldronSprite = newCauldron
        addChild(newCauldron)
        
        printStatus()
    }

    func setupSwitchButton() {
        let button = SKLabelNode(text: "Switch")
        button.name = "switchButton"
        button.fontSize = 20
        button.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1)
        addChild(button)
    }
    
    func setupPotion(with firstIngredient: Ingredient) {
        let potion = Potion(ingredients: [firstIngredient])
        potionSprite = PotionSprite(potion: potion)
        potionSprite.position = selectedCauldronSprite.position
        potionSprite.size = selectedCauldronSprite.size
        potionSprite.setScale(0.65)
        potionSprite.zPosition = 5
        
        addChild(potionSprite)
    }
    
    func updatePotion(with secondIngredient: Ingredient) {
        potionSprite.potion.addIngredient(secondIngredient)
    }
    
    func setupBlock() {
        block = ChoppingBlockSprite(imageNamed: "block")
        block.size = CGSize(width: 350, height: 150)
        block.position = CGPoint(x: size.width * 0.2, y: size.height * 0.75)
        block.zPosition = -5
        addChild(block)
        
        sandboxArea = SandboxArea(color: .darkGray, size: CGSize(width: 250, height: 120))
        sandboxArea.position = CGPoint(x: size.width * 0.55, y: size.height * 0.75)
        addChild(sandboxArea)
    }
    
    func moveIngredientToClickedDestination(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        //switch cauldrons
        if tappedNode.name == "switchButton" {
            switchCauldron()
            return
       }
        
        //select ingredient
        if let ingredient = tappedNode as? IngredientSprite {
            
            guard ingredient.state == .idle || ingredient.state == .chopped else { return }
            
            
            if selectedIngredient == ingredient {
                ingredient.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
                selectedIngredient = nil
            } else {
                selectedIngredient?.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
                selectedIngredient = ingredient
                selectedIngredient?.run(SKAction.scale(to: ingredientScaleSelected, duration: 0.1))
            }
            
            printStatus()
            return
        }
        
        //take ingredient to slot
        if let selected = selectedIngredient as? IngredientSprite {
            
            let sandboxLocation = touch.location(in: sandboxArea)
            
            let moveAction = SKAction.move(to: sandboxLocation, duration: 0.2)

            if let slot = sandboxArea.slotForPosition(sandboxLocation) {
                let added = sandboxArea.addIngredient(selected, to: slot)
                if added {
                    selected.removeFromParent()
                }
            }
        }
        
        //take ingredient to cauldron
        if let selected = selectedIngredient as? IngredientSprite, let cauldronSprite = tappedNode as? CauldronSprite {

            
            let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
            selected.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
            
            var ingredientData = selected.ingredient
            cauldronSprite.cauldron.effect.effect(ingredient: &ingredientData)
            
            selected.run(SKAction.scale(to: 0.2, duration: 0.1))
            
            //add ingredient to cauldron
            cauldronSprite.cauldron.addIngredient(ingredientData)
            if potionSprite == nil {
                setupPotion(with: ingredientData)
            } else {
                updatePotion(with: ingredientData)
            }
            selectedIngredient = nil
            
            printStatus()
            
            // take ingredient to chopping block
        } else if let selected = selectedIngredient as? IngredientSprite, let block = tappedNode as? ChoppingBlockSprite {
            
            let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
            selected.run(moveAction)
            
            selectedIngredient?.state = .choppingBlock
            
            printStatus()
            
        } else if let selected = selectedIngredient {
            selected.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
            selectedIngredient = nil
        }
    }
    
    func updateChopIngredient() {
        guard let ingredientSprite = selectedIngredient else { return }
        guard ingredientSprite.state == .choppingBlock else { return }
        
        if currentNumberClicks == maxNumberClicks {
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
    
    func printStatus() {
        var text = ""

        // Ingrediente selecionado
        if let selected = selectedIngredient {
            let name = selected.ingredient.imageNames.first ?? "?"
            let effect = selected.ingredient.activeEffect?.type.rawValue ?? "Nenhum efeito ativo"
            text += "🧪 Selecionado: \(name)\nEfeito ativo: \(effect)\n\n"
        } else {
            text += "🧪 Nenhum ingrediente selecionado\n\n"
        }

        // Ingredientes no caldeirão
        let ingredients = selectedCauldronSprite.cauldron.ingredients
        text += "🫕 Ingredientes no caldeirão:\n"
        if ingredients.isEmpty {
            text += "- Nenhum\n"
        } else {
            for (index, ing) in ingredients.enumerated() {
                let name = ing.imageNames.first ?? "?"
                let effect = ing.activeEffect?.effectText ?? "sem efeito"
                text += "- \(index+1): \(name) [\(effect)]\n"
            }
        }

        text += "\n💥 Efeitos da poção:\n"
        if let potion = potionSprite?.potion {
            if potion.effects.isEmpty {
                text += "- Nenhum\n"
            } else {
                for effect in potion.effects {
                    text += "- \(effect.effectText)\n"
                }
            }
        } else {
            text += "- Nenhuma poção criada\n"
        }

        statusLabel.text = text
    }
    
    func setupStatusLabel() {
        statusLabel = SKLabelNode(fontNamed: "Courier")
        statusLabel.fontSize = 12
        statusLabel.numberOfLines = 0
        statusLabel.horizontalAlignmentMode = .left
        statusLabel.verticalAlignmentMode = .top
        statusLabel.position = CGPoint(x: size.width * 0.5, y: size.height*0.5)
        statusLabel.zPosition = 100
        statusLabel.preferredMaxLayoutWidth = size.width * 0.4
        addChild(statusLabel)
    }
}
