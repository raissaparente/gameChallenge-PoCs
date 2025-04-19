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
    var currentNumberClicks = 0
    var maxNumberClicks = 20
    
    //MARK: COOKING ACTION
    var didCookPotion = false
    var touchStartTime: TimeInterval?
    
    //MARK: COOKING BAR
    var doneBar: SKSpriteNode!
    var loadingBar: SKSpriteNode!
    let mininumCookingTime = 4.0 //secs
    let maxBarWidth = 150.0
    
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
        setupCookingBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveIngredientToClickedDestination(touches: touches)
        startCookingLongTouch()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopCookingLongTouch()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelCookingLongTouch()
    }
    
    override func update(_ currentTime: TimeInterval) {
        handleCookingBarGrowth(currentTime: currentTime)
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
    
    func clickToChopIngredient() -> Bool {
        guard let ingredientSprite = selectedIngredient as? IngredientSprite else { return false }
        guard currentNumberClicks < maxNumberClicks else { return false  }

        currentNumberClicks += 1
        explodingDicedPieces()
        
        if currentNumberClicks == maxNumberClicks {
            ingredientSprite.ingredient.chooseEffect(isDiced: true)
            ingredientSprite.state = .chopped
        } else if currentNumberClicks > maxNumberClicks-1 {
            ingredientSprite.texture = SKTexture(imageNamed: ingredientSprite.ingredient.imageNames[2])
        } else if currentNumberClicks > 10 {
            ingredientSprite.texture = SKTexture(imageNamed: ingredientSprite.ingredient.imageNames[1])
        }
        print(currentNumberClicks)
        
        return true
    }
    
    func explodingDicedPieces() {
        guard let ingredientSprite = selectedIngredient else { return }
        
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
    
    //MARK: COOKING ACTIONS
    func handleCookingBarGrowth(currentTime: TimeInterval) {
        guard selectedCauldronSprite.cauldron.isCooking else { return }
        
        potionSprite.zRotation += -0.05
        
        if touchStartTime == nil {
            touchStartTime = currentTime
        }
        
        if let startTime = touchStartTime {
            let duration = currentTime - startTime
            let progress = min(duration/mininumCookingTime, 1.0) //fraction of success
            
            let barWidth = maxBarWidth * CGFloat(progress)
            doneBar.size.width = barWidth
            
            
            if duration >= mininumCookingTime {
                didCookPotion = true
                selectedCauldronSprite.cauldron.isCooking = false
            }
        }
        
        if didCookPotion {
            potionSprite.color = .blue
            doneBar.color = .blue
            potionSprite.zRotation = 0
        }
    }
    
    func startCookingLongTouch() {
        guard selectedCauldronSprite.cauldron.isFull else { return }
        
        selectedCauldronSprite.cauldron.isCooking = true
        touchStartTime = nil
        didCookPotion = false
    }
    
    func stopCookingLongTouch() {
        guard selectedCauldronSprite.cauldron.isFull else { return }

        selectedCauldronSprite.cauldron.isCooking = false
        touchStartTime = nil
        
        if !didCookPotion {
            doneBar.size.width = 0
            potionSprite.zRotation = 0
        }
    }
    
    func cancelCookingLongTouch() {
        guard selectedCauldronSprite.cauldron.isFull else { return }

        selectedCauldronSprite.cauldron.isCooking = false
        touchStartTime = nil
    }
    
    
    //MARK: TOUCHES BEGAN BEHAVIOUR
    func moveIngredientToClickedDestination(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        //se nada foi selecionado ainda
        if selectIngredient(tappedNode) { return }
        if tapSwitchCauldronButton(tappedNode) { return }
        
        guard let selected = selectedIngredient else { return }
        switch selected.state {
        case .idle:
            if takeSelectedToSandbox(touch) { return }
            if takeSelectedToCauldron(tappedNode) { return }
            if takeSelectedToBlock(tappedNode) { return }
            
        case .inChoppingBlock:
            if clickToChopIngredient() { return }
            
        case .chopped:
            if takeSelectedToSandbox(touch) { return }
            if takeSelectedToCauldron(tappedNode) { return }
            
        case .inCauldron:
            break
        case .cooking:
            break
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
        
        if selectedIngredient == tappedIngredient {
            desselectIngredient()
        } else {
            //selecionar ingrediente
            selectedIngredient?.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
            selectedIngredient = tappedIngredient
            selectedIngredient?.run(SKAction.scale(to: ingredientScaleSelected, duration: 0.1))
        }
        
        printStatus()
        return true
    }
    
    func desselectIngredient() {
        if let selectedIngredient  {
            selectedIngredient.run(SKAction.scale(to: ingredientScaleNormal, duration: 0.1))
        }
        selectedIngredient = nil
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
        guard let selected = selectedIngredient as? IngredientSprite else { return false }
        
        let sandboxLocation = touch.location(in: sandboxArea)
        guard let slot = sandboxArea.slotForPosition(sandboxLocation) else {
            return false
        }
        
        //clear slots if occupied
        if let _ = sandboxArea.firstSlot.childNode(withName: selected.name!) {
            sandboxArea.clearSlot(sandboxArea.firstSlot)
        } else if (sandboxArea.secondSlot.childNode(withName: selected.name!) != nil) {
            sandboxArea.clearSlot(sandboxArea.secondSlot)
        }
        
        //move to slot
        _ = sandboxArea.addIngredient(selected, to: slot)
        print(selected.position)

        
        desselectIngredient()
        
        return true
    }
    
    func takeSelectedToBlock(_ tappedNode: SKNode) -> Bool{
        guard let selected = selectedIngredient as? IngredientSprite else { return false }
        guard let block = tappedNode as? ChoppingBlockSprite else { return false }
        
        selectedIngredient?.removeFromParent()
        addChild(selected)
        
        let moveAction = SKAction.move(to: tappedNode.position, duration: 0.2)
        selectedIngredient?.run(moveAction)
        
        selectedIngredient?.state = .inChoppingBlock
        printStatus()
        
        //        desselectIngredient()
        
        return true
    }
    
    func takeSelectedToCauldron(_ tappedNode: SKNode) -> Bool{
        guard let selected = selectedIngredient else { return false }
        guard let cauldronSprite = tappedNode as? CauldronSprite else { return false }
        
        print(selected.position, cauldronSprite.position)
                
        //move ingredient to cauldron
        if let ingredientParent = selected.parent {
            guard let convertedCauldronPosition = ingredientParent.convertedPosition(of: cauldronSprite) else { return false }
                
                let moveAction = SKAction.move(to: convertedCauldronPosition, duration: 0.2)
                selected.run(SKAction.sequence([
                    moveAction,
                    SKAction.removeFromParent()
                ]))
            
        }
        
        //add ingredient to cauldron - data
        var ingredientData = selected.ingredient
        cauldronSprite.cauldron.effect.effect(ingredient: &ingredientData)
            
        
        //add ingredient to cauldron - interface
        cauldronSprite.cauldron.addIngredient(ingredientData)
        if potionSprite == nil {
            setupPotion(with: ingredientData)
        } else {
            updatePotion(with: ingredientData)
        }
        
        desselectIngredient()
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
    
    func setupCookingBar() {
        loadingBar = SKSpriteNode(color: .gray, size: CGSize(width: maxBarWidth, height: 20))
        loadingBar.position = CGPoint(x: size.width/2, y: size.height - 100)
        addChild(loadingBar)
        
        doneBar = SKSpriteNode(color: .gray, size: CGSize(width: 0, height: 18))
        doneBar.anchorPoint = CGPoint(x: 0, y: 0)
        let bottomLeftCorner = CGPoint(x: (-loadingBar.size.width/2) + 2.5, y: (-loadingBar.size.height/2)+2.5)
        doneBar.position = bottomLeftCorner
        doneBar.color = .red
        loadingBar.addChild(doneBar)
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

}

extension SKNode {
    //converte de posicao interna do no pra posicao global
    func convertedPosition(of node: SKNode) -> CGPoint? {
        guard let targetParent = node.parent else { return nil }
        return self.convert(node.position, from: targetParent)
    }
}
