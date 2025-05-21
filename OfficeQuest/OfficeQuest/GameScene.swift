import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode? // This is the old "helloLabel"
    private var spinnyNode : SKShapeNode?
    private var player: SKSpriteNode?
    
    private var storyTextNode: SKLabelNode?
    private var storyBeats: [String] = []
    private var currentStoryBeatIndex: Int = 0
    
    private var pauseButtonNode: SKLabelNode?
    private var pauseMenuNode: SKSpriteNode? // Using SKSpriteNode for a background overlay
    
    func setupPauseButton() {
        pauseButtonNode = SKLabelNode(fontNamed: "HelveticaNeue")
        guard let pauseButtonNode = pauseButtonNode else { return }
        
        pauseButtonNode.text = "Pause"
        pauseButtonNode.name = "pauseButton"
        pauseButtonNode.fontSize = 20
        pauseButtonNode.fontColor = SKColor.white
        // Position top-right. Anchor point of SKLabelNode is (0.5, 0.5) by default.
        // Adjusting for anchor point to make it look more like top-right.
        pauseButtonNode.position = CGPoint(x: size.width - pauseButtonNode.frame.size.width/2 - 20, y: size.height - pauseButtonNode.frame.size.height/2 - 20)
        pauseButtonNode.zPosition = 100 // Ensure it's above other game elements but below pause menu
        addChild(pauseButtonNode)
    }
    
    func setupStoryElements() {
        storyTextNode = SKLabelNode(fontNamed: "Helvetica")
        guard let storyTextNode = storyTextNode else {
            print("Story text node could not be initialized.")
            return
        }
        
        storyTextNode.fontSize = 20
        storyTextNode.fontColor = SKColor.white // Assuming a dark background
        storyTextNode.position = CGPoint(x: size.width / 2, y: size.height - 70) // Adjusted Y for better margin
        storyTextNode.zPosition = 100
        storyTextNode.numberOfLines = 0 // Allows for text wrapping
        storyTextNode.preferredMaxLayoutWidth = size.width - 40 // 20px padding on each side
        
        storyBeats = [
            "Ugh, Monday. Another week, another pile of bugs... My name is Alex, and I'm a junior programmer here.",
            "My manager, Mr. Grumbles, just dropped this urgent bug report on my desk. 'Fix the coffee machine alignment!' he said. Coffee machine alignment?! What does that even mean?",
            "Okay, Alex, deep breaths. Let's go investigate this 'critical' coffee machine situation. Maybe it's a pixel off in the UI? Or... is the actual machine levitating?",
            "But first... what's this? Tucked behind a dusty server rack... a perfectly ripe banana! Score! My secret office banana stash always comes through. (+1 HP to Sanity)",
            "(Okay, focus! Coffee machine. Then world domination. Or at least, fewer bugs.)"
        ]
        
        if !storyBeats.isEmpty {
            storyTextNode.text = storyBeats[currentStoryBeatIndex]
        } else {
            storyTextNode.text = "(Story beats not loaded)"
        }
        
        addChild(storyTextNode)
    }
    
    func setupPlayer() {
        // Initialize the player sprite
        player = SKSpriteNode(imageNamed: "programmer_idle.png")

        // Check if player was created successfully
        guard let player = player else {
            print("Player sprite could not be loaded.")
            return
        }

        // Set player's initial position to the center of the screen
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        // Set anchor point to bottom-center
        player.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Add player to the scene
        addChild(player)
    }
    
    override func didMove(to view: SKView) {
        self.setupPlayer()
        self.setupStoryElements() // Call to setup story elements
        self.setupPauseButton()   // Call to setup pause button
        
        // Get label node from scene and store it for use later
        // This is the original "helloLabel", you might want to remove or repurpose it later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0 // Keep it faded out if storyTextNode is primary
            // label.run(SKAction.fadeIn(withDuration: 2.0)) // Or remove this line
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    // The touchDown, touchMoved, and touchUp functions for spinnyNode are kept, 
    // but touchesBegan and touchesMoved will now prioritize player movement.
    // If player movement isn't triggered (e.g. player is nil), these could still be called
    // depending on how the touch handling is structured. For now, they remain as they were.
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }

        
        for t in touches {
            let location = t.location(in: self)
            let touchedNodes = self.nodes(at: location)

            // 1. Check if pause menu is visible
            if let currentPauseMenu = self.pauseMenuNode {
                for node in touchedNodes {
                    if node.name == "resumeButton" {
                        currentPauseMenu.removeFromParent()
                        self.pauseMenuNode = nil
                        self.view?.isPaused = false
                        return // Resume tapped, consume this touch
                    }
                }
                return // If pause menu is visible, but resume not tapped, consume touch anyway
            }

            // 2. If pause menu is NOT visible, check if pause button was tapped
            for node in touchedNodes {
                if node.name == "pauseButton" {
                    self.view?.isPaused = true
                    
                    // Create pause menu overlay
                    self.pauseMenuNode = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.7), size: self.size)
                    guard let newPauseMenu = self.pauseMenuNode else { return }
                    newPauseMenu.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                    newPauseMenu.zPosition = 200 // Very high zPosition
                    
                    // Add "Paused" text
                    let pausedLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
                    pausedLabel.text = "Paused"
                    pausedLabel.fontSize = 36
                    pausedLabel.fontColor = SKColor.white
                    pausedLabel.position = CGPoint(x: 0, y: 50) // Centered on the overlay
                    newPauseMenu.addChild(pausedLabel)
                    
                    // Add "Resume" button
                    let resumeButtonLabel = SKLabelNode(fontNamed: "HelveticaNeue")
                    resumeButtonLabel.text = "Resume"
                    resumeButtonLabel.name = "resumeButton"
                    resumeButtonLabel.fontSize = 28
                    resumeButtonLabel.fontColor = SKColor.cyan
                    resumeButtonLabel.position = CGPoint(x: 0, y: -30) // Below "Paused" text
                    newPauseMenu.addChild(resumeButtonLabel)
                    
                    self.addChild(newPauseMenu)
                    return // Pause button tapped, consume this touch
                }
            }

            // 3. If pause menu not visible AND pause button not tapped, proceed with game actions
            // Player guard for game actions
            guard let player = self.player else { return }

            if t.tapCount == 2 {
                // Double-tap detected
                self.interact()
            } else if t.tapCount == 1 {
                // Single-tap detected for movement/jump
                let location = t.location(in: self) // location already defined, reuse
                let movementAreaHeight = self.size.height * 0.20

                if location.y < movementAreaHeight {
                    let moveAmount: CGFloat = 30.0
                    let moveDuration: TimeInterval = 0.1
                    if location.x < self.size.width / 2 {
                        player.run(SKAction.moveBy(x: -moveAmount, y: 0, duration: moveDuration))
                    } else {
                        player.run(SKAction.moveBy(x: moveAmount, y: 0, duration: moveDuration))
                    }
                } else {
                    let jumpUpAction = SKAction.moveBy(x: 0, y: 100, duration: 0.2)
                    let jumpDownAction = SKAction.moveBy(x: 0, y: -100, duration: 0.3)
                    player.run(SKAction.sequence([jumpUpAction, jumpDownAction]))
                }
            }
        }
    }
    
    func interact() {
        // print("Player interacted") // Original print statement, can be removed
        
        guard let storyTextNode = self.storyTextNode else {
            print("Story text node is not available to update.")
            return
        }
        
        currentStoryBeatIndex += 1
        
        let bananaBeatIdentifier = "But first... what's this? Tucked behind a dusty server rack... a perfectly ripe banana! Score! My secret office banana stash always comes through. (+1 HP to Sanity)"

        if currentStoryBeatIndex < storyBeats.count {
            let currentText = storyBeats[currentStoryBeatIndex]
            storyTextNode.text = currentText
            
            if currentText == bananaBeatIdentifier {
                storyTextNode.fontColor = SKColor.green
            } else {
                storyTextNode.fontColor = SKColor.white
            }
        } else {
            storyTextNode.text = "(Double-tap to interact with things when you find them!)"
            storyTextNode.fontColor = SKColor.white // Ensure default color for generic message
            // Optionally, you could hide the storyTextNode or reset the index
            // if currentStoryBeatIndex > storyBeats.count + some_threshold to allow re-reading intro
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Movement logic removed from touchesMoved as per subtask instructions
        // guard let player = self.player else { return } 

        // for t in touches {
        //     let location = t.location(in: self)
        //     // ... existing logic commented out or removed ...
        // }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Original spinnyNode logic for touchesEnded can remain if desired,
        // or can be removed if player interaction should be the sole focus.
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
