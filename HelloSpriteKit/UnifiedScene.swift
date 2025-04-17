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
    
    
    func updatePotion(with secondIngredient: Ingredient) {
        potionSprite.potion.addIngredient(secondIngredient)
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
    
    //MARK: TOUCHES BEGAN BEHAVIOUR
    func moveIngredientToClickedDestination(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        if tapSwitchCauldronButton(tappedNode) { return }
        if selectIngredient(tappedNode) { return }
        if takeSelectedToSandbox(touch) { return }
        if takeSelectedToCauldron(tappedNode) { return }
        if takeSelectedToBlock(tappedNode) { return }
            
        if let selected = selectedIngredient {
            selected.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
            selectedIngredient = nil
        }
    }
    
    func tapSwitchCauldronButton(_ tappedNode: SKNode) -> Bool {
        guard tappedNode.name == "switchButton" else { return false }
        switchCauldron()
        return true
    }
    
    func selectIngredient(_ tappedNode: SKNode) -> Bool {
        guard let tappedIngredient = tappedNode as? IngredientSprite else { return false }
        
        //trocar ingredientes
        if let selected = selectedIngredient, selected != tappedIngredient {
            swapSelectedIngredient(selected, with: tappedIngredient)
        }
            
        guard tappedIngredient.state == .idle || tappedIngredient.state == .chopped else { return false }
            
        //selecionar ingrediente
        if selectedIngredient == tappedIngredient {
            tappedIngredient.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
            selectedIngredient = nil
        } else {
            selectedIngredient?.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
            selectedIngredient = tappedIngredient
            selectedIngredient?.run(SKAction.scale(to: ingredientScaleSelected, duration: 0.1))
        }
            
        printStatus()
        return true
    }

    func swapSelectedIngredient(_ selected: IngredientSprite, with newIngredient: IngredientSprite) {
        let posicao = selected.position
        
        let moveAction = SKAction.move(to: newIngredient.position, duration: 0.3)
        selected.run(moveAction)
        print("moveu o primeiro pro segundo")
        
        let moveAction2 = SKAction.move(to: posicao, duration: 0.2)
        newIngredient.run(moveAction2)
        print("moveu o segundo pro primeiro")
    }
    
    func takeSelectedToSandbox(_ touch: UITouch) -> Bool {
        guard let selected = selectedIngredient else { return false }
            
        let sandboxLocation = touch.location(in: sandboxArea)
        let moveAction = SKAction.move(to: sandboxLocation, duration: 0.2)
        
        if let _ = sandboxArea.firstSlot.childNode(withName: selected.name!) {
            sandboxArea.clearSlot(sandboxArea.firstSlot)
        } else if (sandboxArea.secondSlot.childNode(withName: selected.name!) != nil) {
            sandboxArea.clearSlot(sandboxArea.secondSlot)
        }
        
        if let slot = sandboxArea.slotForPosition(sandboxLocation) {
            let added = sandboxArea.addIngredient(selected, to: slot)
        }
        
        return true
    }
    
    func takeSelectedToBlock(_ tappedNode: SKNode) -> Bool{
        guard let selected = selectedIngredient as? IngredientSprite else { return false }
        guard let block = tappedNode as? ChoppingBlockSprite else { return false }
        
            selectedIngredient?.removeFromParent()
            addChild(selected)
            
            let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
            selectedIngredient?.run(moveAction)
            
            selectedIngredient?.state = .choppingBlock
                        printStatus()
        return true
    }
    
    func takeSelectedToCauldron(_ tappedNode: SKNode) -> Bool{
        guard let selected = selectedIngredient else { return false }
        guard let cauldronSprite = tappedNode as? CauldronSprite else { return false }
            
        //move ingredient to cauldron
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
        return true
    }
    
    
    //MARK: SETUP UI
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

    func setupPotion(with firstIngredient: Ingredient) {
        let potion = Potion(ingredients: [firstIngredient])
        potionSprite = PotionSprite(potion: potion)
        potionSprite.position = selectedCauldronSprite.position
        potionSprite.size = selectedCauldronSprite.size
        potionSprite.setScale(0.65)
        potionSprite.zPosition = 5
        
        addChild(potionSprite)
    }
    
    func setupSwitchButton() {
        let button = SKLabelNode(text: "Switch")
        button.name = "switchButton"
        button.fontSize = 20
        button.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1)
        addChild(button)
    }
    
    func setupStatusLabel() {
        statusLabel = SKLabelNode()
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
