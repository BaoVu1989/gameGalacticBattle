//
//  GameScene.swift
//  New_Shoot
//
//  Created by Bao Vu on 2/3/20.
//  Copyright © 2020 Bao Vu. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreLocation
import UIKit

var gameScore = 0
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var player : SKSpriteNode!
    //var bullet : SKSpriteNode!
    var enemy : SKSpriteNode!
    let player = SKSpriteNode(imageNamed: "Rocketplayer.png")
    
    
    
    let scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    var levelNumber = 0
    var livesNumber = 3
    
    let livesLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    var currentGameState = gameState.preGame
    
    let bulletSound = SKAction.playSoundFileNamed("Gunsound.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("Explode.mp3", waitForCompletion: false)
        enum vatThe:UInt32{
        case nhomBullet = 1
        case nhomEnemy = 2
        case nhomPlayer = 3
    }
    
        
    func random() -> CGFloat{
        return CGFloat(CGFloat(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    
    var gameArea: CGRect
    
    override init(size: CGSize) {
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
        //iPhone X
        let maxAspectRatio: CGFloat = 19.5/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        } else {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        }
            super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Wrong")
    }
   
    
    
    var possibleEnemies = ["enemy", "enemy1", "enemy2"]
    
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background.png")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        player.size = CGSize(width: 100, height: 200)
        player.position = CGPoint(x: self.size.width/2, y: -player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        
        player.physicsBody?.categoryBitMask = vatThe.nhomPlayer.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = vatThe.nhomEnemy.rawValue
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = UIColor.green
        scoreLabel.fontSize = 80
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 80
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.5)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        tapToStartLabel.text = "TAP TO BEGIN"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.yellow
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.1)
        tapToStartLabel.run(fadeInAction)
        
        
    }
    func spawEnemy(){
           
           let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
           let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
           let startPoint = CGPoint(x: randomXStart, y: self.size.height )
           let endPoint = CGPoint(x: randomXEnd, y: 0 - self.size.height * 0.01)
           possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
           enemy = SKSpriteNode(imageNamed: possibleEnemies[0])
           
           //enemy.name = "Enemy"
           enemy.position = startPoint
           enemy.size = CGSize(width: 100, height: 100)
           enemy.zPosition = 1
           enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
           enemy.physicsBody!.affectedByGravity = false
           enemy.physicsBody?.categoryBitMask = vatThe.nhomEnemy.rawValue
           enemy.physicsBody?.collisionBitMask = 0
           enemy.physicsBody?.contactTestBitMask = vatThe.nhomBullet.rawValue | vatThe.nhomPlayer.rawValue
           self.addChild(enemy)
       
        let moveEnemy = SKAction.move(to: endPoint, duration: 7.0)
           let deleteEnemy = SKAction.removeFromParent()
           let loseLivesAction = SKAction.run(loseLives)
           let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLivesAction])
           
          if currentGameState == gameState.inGame{
           enemy.run(enemySequence)
               
          }
       }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body2 = contact.bodyA
            body1 = contact.bodyB
        }
        
        if body1.categoryBitMask == vatThe.nhomEnemy.rawValue && body2.categoryBitMask == vatThe.nhomPlayer.rawValue{
            spawnExplosion(spawnPosition: enemy.position)
            spawnExplosion(spawnPosition: player.position)
            body2.node?.removeFromParent()
            body1.node?.removeFromParent()
            
            runGameOver()
        }
        if body1.categoryBitMask == vatThe.nhomBullet.rawValue && body2.categoryBitMask == vatThe.nhomEnemy.rawValue{
           
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
            }
           
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            addScore()
            
        }
        

    }
    
    func addScore(){
        
        gameScore += 5
        scoreLabel.text = "Lives: \(gameScore)"
        
        if gameScore == 50 || gameScore == 100 || gameScore == 150{
            startNewLevel()
        }
    }
    
    func loseLives(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
          livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
    }
    
    func runGameOver(){
        currentGameState = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") {
            (bullet, stop) in bullet.removeAllActions()
        }
        enemy.removeAllActions()
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.name = "Bullet"
        bullet.size = CGSize(width: 100, height: 100)
        bullet.position = player.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = vatThe.nhomBullet.rawValue
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.contactTestBitMask = vatThe.nhomEnemy.rawValue
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 0.5)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func startGame(){
        currentGameState = gameState.inGame
        let fadeOutAction = SKAction.fadeIn(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let movePlayerOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.4)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([movePlayerOntoScreenAction, startLevelAction])
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
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            if currentGameState == gameState.inGame{
            player.position.x += amountDragged
            }
           if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
   
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        
        switch levelDuration {
        case 1:
            levelDuration = 3
        case 2:
            levelDuration = 2
        case 3:
            levelDuration = 1
        case 4:
            levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion.png")
        explosion.size = CGSize(width: 100, height: 200)
        explosion.position = spawnPosition
        explosion.zPosition = 3
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
       

}
