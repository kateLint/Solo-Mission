//
//  GameScene.swift
//  Solo Mission
//
//  Created by Chukcha on 22/03/2020.
//  Copyright © 2020 KateLint. All rights reserved.
//

import SpriteKit
import GameplayKit
    var gameScore = 0
class GameScene: SKScene, SKPhysicsContactDelegate {

    var levelNumber = 0
    var lifesNumber = 3
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let lifesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
    let explositioSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    var gameArea = CGRect()
    
    enum gameState{
        case preGame //when the game state
        case inGame //is during
        case afterGame //when the after
    }
    
    var currentGameState = gameState.preGame
    
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 1 //0b1
        static let Bullet: UInt32 = 2 //0b10
        static let Enemy: UInt32 = 4 //0b100
    }
    
    func random(min : CGFloat, max: CGFloat)-> CGFloat{
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playbleWith = size.height/maxAspectRatio
        let margin = (size.width - playbleWith)/2
        gameArea = CGRect(x: margin, y:0, width: playbleWith, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){
        
        gameScore = 0
        self.physicsWorld.contactDelegate = self // physick contact in scene
        
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.name = "Background"
            background.anchorPoint = CGPoint(x: 0.5, y: 0) //anchor point at the bottom
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            self.addChild(background)
        }
        
        player.size.width = 100
        player.size.height = 100
        player.position = CGPoint(x: self.size.width/2, y:0-player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        lifesLabel.text = "Lifes: 3"
        lifesLabel.fontSize = 70
        lifesLabel.fontColor = SKColor.white
        lifesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        lifesLabel.position = CGPoint(x: self.size.width*0.65, y: self.size.height+lifesLabel.frame.size.height) // start above the screne
        lifesLabel.zPosition = 100 //alwayes on top
        self.addChild(lifesLabel)
        
        let moveToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveToScreenAction)
        lifesLabel.run(moveToScreenAction)
        
        
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        tapToStartLabel.zPosition = 1 //alwayes on top
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
  
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosition")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let scaleOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explotionSequence = SKAction.sequence([scaleIn, scaleOut, delete])
        //let explotionSequence = SKAction.sequence([explotionSound,scaleIn, scaleOut, delete])
        explosion.run(explotionSequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
      
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            //Player hit the enemy
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if(body2.node != nil){
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            runGameOver()
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height{
            //body2.node?.position.y < self.size.height enemy on the screne
            //if the bullet has hit the enemy
            if(body2.node != nil){
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            addScore()
            body1.node?.removeFromParent() // delete bullet
            body2.node?.removeFromParent() //delete enemy
        }
    }
    
    
    func fireBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1 )
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound,moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
  
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previuosPointOftouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previuosPointOftouch.x //gap between were and now
            if currentGameState == gameState.inGame{
                player.position.x+=amountDragged
            }
           
            
           if player.position.x >= gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
             // Too far left
             if player.position.x <= gameArea.minX + player.size.width/2 {
                    player.position.x = gameArea.minX + player.size.width/2
             }


        }
    }
    
    
    func spawnEnemy(){
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.size.height = 100
        enemy.size.width = 100
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let looseALifeVar = SKAction.run(looseALife)
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy,looseALifeVar])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy,dx)
        
        enemy.zRotation = amountToRotate
        
    }
    
    func startNewLevel(){
        levelNumber+=1
        
        if( self.action(forKey: "spawingEnemies") != nil){
            self.removeAction(forKey: "spawingEnemies")
        }
        
        var levelDuration = TimeInterval()
        switch levelNumber{
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Connot find level info")
        }
        
        let spawn =  SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn,spawn]) //wait and then spawn
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawingEnemies")
    }
    func looseALife(){
        lifesNumber-=1
          lifesLabel.text = "Lifes: \(lifesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        lifesLabel.run(scaleSequence)
        
        if(lifesNumber == 0){
            runGameOver()
        }
        
    }
    func addScore(){
          gameScore+=1
          scoreLabel.text = "Score: \(gameScore)"
        if (gameScore == 10 || gameScore == 25 || gameScore == 50){ //levels
            startNewLevel()
        }
      }
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        //all bullet in the scene
        self.enumerateChildNodes(withName: "Bullet"){bullet,stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){enemy,stop in
                   enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
  func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size) //Argument passed to call that takes no arguments
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 1)
        self.view!.presentScene(sceneToMoveTo,transition: myTransition)
    }

    func startGame(){
        currentGameState = gameState.inGame
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut,deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreen = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreen, startLevelAction])
        player.run(startGameSequence)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame{
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireBullet()
        }
    
    }
    
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 300.0 //300 makes the scrolling BG Slower
    
    override func update(_ currentTime: TimeInterval) { //once per frame
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime //time thaat past from last frame
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background") {
            (background, stop) in
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
    }
    
}
