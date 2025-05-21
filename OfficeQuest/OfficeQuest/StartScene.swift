import SpriteKit

class StartScene: SKScene {

    override func didMove(to view: SKView) {
        // Set background color
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0) // Dark gray

        // Add game title
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        titleLabel.text = "Office Quest"
        titleLabel.fontSize = 48
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)

        // Add start game button
        let startGameLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        startGameLabel.text = "Tap to Start"
        startGameLabel.fontSize = 32
        startGameLabel.fontColor = SKColor.cyan
        startGameLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        startGameLabel.name = "startButton" // Assign a name for touch detection
        addChild(startGameLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNodes = nodes(at: touchLocation)

        for node in touchedNodes {
            if node.name == "startButton" {
                // Transition to GameScene
                if let view = self.view {
                    let gameScene = GameScene(size: self.size) // Use self.size for consistency
                    gameScene.scaleMode = .aspectFill
                    
                    let transition = SKTransition.fade(withDuration: 1.0)
                    view.presentScene(gameScene, transition: transition)
                }
                break // Stop checking other nodes once the button is found
            }
        }
    }
}
