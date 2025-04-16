import SpriteKit

class SandboxArea: SKSpriteNode {
    
    let firstSlot = SKSpriteNode(color: .cyan, size: CGSize(width: 80, height: 80))
    let secondSlot = SKSpriteNode(color: .orange, size: CGSize(width: 80, height: 80))
    
    private var firstIngredient: SKSpriteNode?
    private var secondIngredient: SKSpriteNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = false
        
        firstSlot.name = "firstSlot"
        secondSlot.name = "secondSlot"
        
        firstSlot.position = CGPoint(x: -size.width / 4, y: 0)
        secondSlot.position = CGPoint(x: size.width / 4, y: 0)
        
        let label1 = SKLabelNode(text: "#1")
        label1.fontSize = 20
        label1.fontColor = .white
        label1.position = CGPoint(x: 0, y: -firstSlot.size.height / 2 - 20)
        firstSlot.addChild(label1)
        
        let label2 = SKLabelNode(text: "#2")
        label2.fontSize = 20
        label2.fontColor = .white
        label2.position = CGPoint(x: 0, y: -secondSlot.size.height / 2 - 20)
        secondSlot.addChild(label2)
        
        addChild(firstSlot)
        addChild(secondSlot)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addIngredient(_ ingredient: SKSpriteNode, to slot: SKSpriteNode) -> Bool {
        if slot == firstSlot && firstIngredient == nil {
            ingredient.position = .zero
            ingredient.removeFromParent()
            firstSlot.addChild(ingredient)
            firstIngredient = ingredient
            return true
        } else if slot == secondSlot && secondIngredient == nil {
            ingredient.position = .zero
            ingredient.removeFromParent()
            secondSlot.addChild(ingredient)
            secondIngredient = ingredient
            return true
        }
        
        return false // Slot já está ocupado
    }
    
    func clearSlot(_ slot: SKSpriteNode) {
        if slot == firstSlot {
            firstIngredient?.removeFromParent()
            firstIngredient = nil
        } else if slot == secondSlot {
            secondIngredient?.removeFromParent()
            secondIngredient = nil
        }
    }
    
    func slotForPosition(_ position: CGPoint) -> SKSpriteNode? {
        if firstSlot.contains(position) { return firstSlot }
        if secondSlot.contains(position) { return secondSlot }
        return nil
    }
    
    func isSlotAvailable(_ slot: SKSpriteNode) -> Bool {
        if slot == firstSlot { return firstIngredient == nil }
        if slot == secondSlot { return secondIngredient == nil }
        return false
    }
}
