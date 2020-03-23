//
//  GameViewController.swift
//  Solo Mission
//
//  Created by Chukcha on 22/03/2020.
//  Copyright © 2020 KateLint. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    var backingAudio = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Playing a track
        //Backing Audio - this is the name of the file
        let filePath = Bundle.main.path(forResource: "BackingAudio", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL) }
        catch { return print("Cannot Find Audio") }
        
        backingAudio.numberOfLoops = -1
        backingAudio.play()
        //---------------end playing track-----------------
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
         //  let scene = SKScene(fileNamed: "MainMenuScene")
            // if let scene = SKScene(fileNamed: "MainMenuScene") {
               let scene = MainMenuScene(size: CGSize(width: 1048, height: 2048))

                // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
        //    }
            
            
            view.ignoresSiblingOrder = true
            
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
