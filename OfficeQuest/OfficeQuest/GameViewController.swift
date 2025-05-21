import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Create an instance of StartScene
            let scene = StartScene(size: view.bounds.size)
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the StartScene
            view.presentScene(scene)
            
            // The old code for loading GameScene.sks directly is now replaced.
            // if let scene = SKScene(fileNamed: "GameScene") {
            //     scene.scaleMode = .aspectFill
            //     view.presentScene(scene)
            // }
            
            view.ignoresSiblingOrder = true
            
            // It's good practice to keep these for debugging during development,
            // they can be removed for release builds.
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
