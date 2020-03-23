//
//  MainMenuScene.swift
//  Solo Mission
//
//  Created by Chukcha on 23/03/2020.
//  Copyright © 2020 KateLint. All rights reserved.
//

import Foundation
import SpriteKit
class MainMenuScene : SKScene{
    override func didMove(to view: SKView) {
      let background = SKSpriteNode(imageNamed: "background")
               background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
               background.zPosition = 0
               self.addChild(background)
               
               let gameBy = SKLabelNode(fontNamed: "The Bold Font")
               gameBy.text = "Katya Lint"
               gameBy.fontSize = 40
               gameBy.fontColor = SKColor.white
               gameBy.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.64)
               self.addChild(gameBy)
               
               let gameName = SKLabelNode(fontNamed: "The Bold Font")
               gameName.text = "Solo"
               gameName.fontSize = 80
               gameName.fontColor = SKColor.white
            gameName.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.6)
               gameName.zPosition = 1
               self.addChild(gameName)
        
        
              let gameName2 = SKLabelNode(fontNamed: "The Bold Font")
                    gameName2.text = "Mission"
                    gameName2.fontSize = 80
                    gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.55)
                    gameName2.zPosition = 1
                    self.addChild(gameName2)
        
        
              let startGame = SKLabelNode(fontNamed: "The Bold Font")
                    startGame.text = "Start Game"
                    startGame.fontSize = 100
        startGame.name = "startButton"
                    startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.4)
                    startGame.zPosition = 1
                    self.addChild(startGame)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let pointOftouch = touch.location(in: self)
            let nodeIsTapped = atPoint(pointOftouch)
            if(nodeIsTapped.name == "startButton"){
                let sceneToMoveTo = GameScene(size: self.size)
                 sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo,transition: myTransition)
            }
            
      
    
        }
    }

}
