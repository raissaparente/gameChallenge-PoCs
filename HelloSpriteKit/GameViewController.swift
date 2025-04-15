import UIKit
import SpriteKit

class GameViewController: UIViewController {

    let skView = SKView()
    var scene: UnifiedScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSKView()
    }
    
    private func setupSKView() {
        view.addSubview(skView)
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            skView.leftAnchor.constraint(equalTo: view.leftAnchor),
            skView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
    }
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         
         if scene == nil {
             scene = UnifiedScene(size: skView.bounds.size)
             scene?.scaleMode = .resizeFill
             skView.presentScene(scene)
         }
     }
}

