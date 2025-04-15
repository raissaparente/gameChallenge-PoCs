import SpriteKit

class SpinCauldronScene: SKScene {
    var isTouching = false
    var potion: SKSpriteNode!
    var doneBar: SKSpriteNode!
    var loadingBar: SKSpriteNode!
    
    var touchStartTime: TimeInterval?
    let mininumCookingTime = 4.0 //secs
    let maxBarWidth = 245.0
    var didCookPotion = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupSprites()

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
        touchStartTime = nil
        didCookPotion = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        touchStartTime = nil
        
        if !didCookPotion {
            doneBar.size.width = 0
            potion.zRotation = 0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        touchStartTime = nil

    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isTouching else { return }
        
        potion.zRotation += -0.05
        
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
                isTouching = false
            }
        }
        
        if didCookPotion {
            potion.color = .blue
            doneBar.color = .blue
            potion.zRotation = 0
        }
    }
    
    func setupSprites() {
        let title = SKLabelNode(text: "Cooking PoC")
        title.fontColor = .white
        title.fontSize = 50
        title.position = CGPoint(x: size.width/2, y: size.height - 50)
        addChild(title)
        
        loadingBar = SKSpriteNode(color: .gray, size: CGSize(width: 250, height: 30))
        loadingBar.position = CGPoint(x: size.width/2, y: size.height - 100)
        addChild(loadingBar)
        
        doneBar = SKSpriteNode(color: .gray, size: CGSize(width: 0, height: 25))
        doneBar.anchorPoint = CGPoint(x: 0, y: 0)
        let bottomLeftCorner = CGPoint(x: (-loadingBar.size.width/2) + 2.5, y: (-loadingBar.size.height/2)+2.5)
        doneBar.position = bottomLeftCorner
        doneBar.color = .red
        loadingBar.addChild(doneBar)
        
        let pan = SKSpriteNode(color: .gray, size: CGSize(width: 200, height: 200))
        pan.position = CGPoint(x: size.width/2, y: size.height/2)
        pan.zPosition = 1
        addChild(pan)
        
        potion = SKSpriteNode(color: .red, size: CGSize(width: 150, height: 150))
        potion.position = CGPoint(x: size.width/2, y: size.height/2)
        potion.zPosition = 4
        addChild(potion)
    }
        
}
