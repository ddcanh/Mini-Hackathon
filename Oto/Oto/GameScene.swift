//
//  GameScene.swift
//  Oto
//
//  Created by Enrik on 9/10/16.
//  Copyright (c) 2016 Enrik. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let margin: CGFloat = 20
    
    var backGround1: SKSpriteNode!
    var backGround2: SKSpriteNode!
    var backgroundMusic: SKAudioNode!
    var backGroundSpeed: CGFloat!
    
    
    var player: SKSpriteNode!
    var police: SKSpriteNode!
    var bridge1:SKSpriteNode!
    var bridge2:SKSpriteNode!
    
    var enemys = [SKSpriteNode]()
    var powers = [SKSpriteNode]()
    var trees = [SKSpriteNode]()
    
    var health: CGFloat = 50
    var maxHealth: CGFloat = 80
    
    var previousTime: CFTimeInterval = -1
    var countForE = 0
    var countForP = 0
    var minTime: CFTimeInterval = 2
    var score = 0
    var scoreLabel: SKLabelNode!
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        addBackGround()
        addBackgroundMusic()
        addScore()
        addPlayer()
        addPolice()
        addBridge()
        addTree()
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
            let currentLocation = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            
            let dx = currentLocation.x - previousLocation.x
            
            player.position = CGPoint(x: player.position.x + dx, y: player.position.y)
            
            if player.position.x < player.frame.width/2 + margin  {
                player.position.x = player.frame.width/2 + margin
            } else if player.position.x > self.frame.width - player.frame.width/2 - margin {
                player.position.x = self.frame.width - player.frame.width/2 - margin
            }
            
        }
        
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
        var enemySpeed: CGFloat = 10
        if score < 200 {
            minTime = 3
            
        } else if score < 900 {
            minTime = 2
            enemySpeed = 15
        } else  {
            minTime = 1
            enemySpeed = 30
        }
        
        updateScore()
        
        if score < 900 {
            backGroundSpeed = CGFloat(score/30)
        } else {
            backGroundSpeed = 30
        }
        scrollBackGround(backGroundSpeed)
        
        if previousTime == -1 {
            previousTime = currentTime
        } else {
            let delta = currentTime - previousTime
            
            if delta > minTime {
                countForE += 1
                countForP += 1
                previousTime = currentTime
                
            }
            
            if countForE == 1{
                addEnemy(enemySpeed)
                countForE = 0
            }
            
            if countForP == 10{
                addPower()
                countForP = 0
            }
            
        }
        
        
        
        updateEnemys()
        updatePower()
        updatePolice()
        checkIntersectTree()
        // move police toward player
        movePolice(3,speedY: 1)
        
        if health > maxHealth {
            health = maxHealth
        }
    }
    
    func checkIntersectTree() {
        for tree in trees {
            if CGRectIntersectsRect(tree.frame, player.frame) {
                health -= 5
            }
        }
    }
    
    func updateEnemys() {
        /* ENEMYS */
        
        //check collision player vs cars
        for (enemyIndex,enemy) in enemys.enumerate() {
            if CGRectIntersectsRect(enemy.frame, player.frame) {
                enemy.removeFromParent()
                enemys.removeAtIndex(enemyIndex)
                health -= 10
            }
        }
        
        // remove car when move beyond the screen
        for (enemyIndex,enemy) in enemys.enumerate() {
            if enemy.position.y < -enemy.frame.height/2 {
                enemys.removeAtIndex(enemyIndex)
                enemy.removeFromParent()
            }
        }
        
    }
    
    func updatePower() {
        /* POWER */
        
        //check get power
        for (powerIndex,power) in powers.enumerate() {
            if CGRectIntersectsRect(power.frame, player.frame) {
                power.removeFromParent()
                powers.removeAtIndex(powerIndex)
                health += 10
            }
        }
        
        // remove power when disappear
        for (powerIndex,power) in powers.enumerate() {
            if power.position.y < 0 {
                powers.removeAtIndex(powerIndex)
            }
        }
        
    }
    
    func updatePolice() {
        /* POLICE */
        
        // check interset police vs cars
        for (enemyIndex,enemy) in enemys.enumerate() {
            if CGRectIntersectsRect(enemy.frame, police.frame) {
                enemy.removeFromParent()
                enemys.removeAtIndex(enemyIndex)
                health += 5
            }
        }
        
        // check intersect police vs player
        if CGRectIntersectsRect(player.frame, police.frame) {
            self.paused = true
            player.removeFromParent()
            gameOver()
        }
        
    }
    
    func movePolice(speedX: CGFloat, speedY: CGFloat) {
        if police.position.x < player.position.x - speedX {
            police.position.x += speedX
        } else if police.position.x > player.position.x + speedX {
            police.position.x -= speedX
        }
        
        let positionY = player.position.y - player.frame.height/2 - police.frame.height/2 - health
        
        if police.position.y < positionY {
            police.position.y += speedY
        } else if police.position.y > positionY {
            police.position.y -= speedY
        }
    }
    
    
    func addPower() {
        // init
        let power = SKSpriteNode(imageNamed: "health")
        
        var isIntersectCar = true
        
        while isIntersectCar == true {
            isIntersectCar = false
            
            let postionX = CGFloat(arc4random_uniform(UInt32(self.frame.maxX - power.frame.width - margin * 2))) + power.frame.width/2 + margin
            
            power.position = CGPoint(x: postionX, y: self.frame.maxY)
            
            for enemy in enemys {
                if CGRectIntersectsRect(enemy.frame, power.frame) {
                    isIntersectCar = true
                    break
                }
            }
        }
        
        
        // add action
        let actionRun = SKAction.moveByX(0, y: -10, duration: 0.1)
        power.runAction(SKAction.repeatActionForever(actionRun))
        
        powers.append(power)
        
        addChild(power)
    }
    
    func addEnemy(speed: CGFloat) {
        
        let marginSpeed = CGFloat(arc4random_uniform(20))
        
        // set random image
        let randomNumber = Int(arc4random_uniform(3)) + 1
        let imageName = "EnemyCar\(randomNumber)"
        let enemy = SKSpriteNode(imageNamed: imageName)
        
        // set postion
        let postionX = CGFloat(arc4random_uniform(UInt32(self.frame.maxX - enemy.frame.width - margin * 2))) + enemy.frame.width/2 + margin
        enemy.position = CGPoint(x: postionX, y: self.frame.maxY)
        
        // add action run
        let fallSpeed = speed + marginSpeed
        
        let actionRun = SKAction.moveByX(0, y:-fallSpeed, duration: 0.1)
        enemy.runAction(SKAction.repeatActionForever(actionRun))
        addChild(enemy)
        
        
        enemys.append(enemy)
        
        
    }
    
    func addBackGround(){
        backGround1 = SKSpriteNode(imageNamed: "backGround")
        backGround2 = SKSpriteNode(imageNamed: "backGround")
        
        backGround1.anchorPoint = CGPointZero
        backGround1.position = CGPointZero
        
        backGround2.anchorPoint = CGPointZero
        backGround2.position = CGPoint(x: backGround1.position.x, y: self.frame.height)
        
        backGround1.size = self.frame.size
        backGround2.size = self.frame.size
        
        addChild(backGround1)
        addChild(backGround2)
    }
    
    func scrollBackGround(speed: CGFloat){
        backGround1.position = CGPoint(x: backGround1.position.x, y: backGround1.position.y - speed)
        backGround2.position = CGPoint(x: backGround2.position.x, y: backGround2.position.y - speed)
        
        if backGround1.position.y < -backGround1.frame.height  {
            backGround1.position.y = backGround2.position.y + backGround2.frame.height - 10
        }
        
        if backGround2.position.y < -backGround2.frame.height  {
            backGround2.position.y = backGround1.position.y + backGround1.frame.height
        }
        
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Car")
        player.position = CGPoint(x: self.frame.width/2, y: 150)
        player.parent
        
        addChild(player)
    }
    
    func addPolice() {
        police = SKSpriteNode(imageNamed: "PoliceCar2")
        
        police.position = CGPoint(x: player.position.x, y: player.position.y - player.frame.height/2 - police.frame.height/2 - health)
        
        addChild(police)
        
    }
    
    func addBridge() {
        bridge2 = SKSpriteNode(imageNamed: "bridge2.png")
        bridge2.position = CGPoint(x: backGround1.position.x + backGround1.size.width/2 , y: backGround1.position.y)
        
        bridge2.zPosition = 101
        backGround2.addChild(bridge2)
    }
    
    func addTree() {
        let tree1 = SKSpriteNode(imageNamed: "tree.png")
        tree1.size = CGSize(width: 22, height: 36)
        tree1.position = CGPoint(x: backGround2.position.x + backGround2.size.width - 11 , y:backGround2.size.height)
        
        let tree2 = SKSpriteNode(imageNamed: "tree.png")
        tree2.size = CGSize(width: 22,height: 36)
        tree2.position = CGPoint(x: backGround2.position.x + backGround2.size.width - 11 , y:backGround2.size.height - 220 )
        
        let tree3 = SKSpriteNode(imageNamed: "tree.png")
        tree3.size = CGSize(width: 22,height: 36)
        tree3.position = CGPoint(x: backGround2.position.x + 11, y: backGround2.size.height - 50 )
        
        tree3.zRotation = 3.14
        
        trees = [tree1, tree2, tree3]
        backGround2.addChild(tree2)
        backGround2.addChild(tree1)
        backGround2.addChild(tree3)
    }
    
    func addBackgroundMusic() {
        if let musicURL = NSBundle.mainBundle().URLForResource("backGround_Sound", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(URL: musicURL)
            addChild(backgroundMusic)
        }
        
    }
    
    func updateScore() {
        score += 1
        scoreLabel.text = String(score)
    }
    
    func addScore() {
        let scoreText = SKLabelNode(text: "Score:")
        scoreText.fontColor = UIColor.blueColor()
        scoreText.fontSize = 15
        scoreText.fontName = "Verdana-Bold"
        scoreText.position = CGPoint(x: self.frame.width - 100, y: self.frame.height - 15)
        addChild(scoreText)
        
        scoreLabel = SKLabelNode(text: String(score))
        scoreLabel.fontColor = UIColor.blueColor()
        scoreLabel.fontSize = 15
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.fontName = "Verdana-Bold"
        scoreLabel.position = CGPoint(x: self.frame.width - 50, y: self.frame.height - 15)
        addChild(scoreLabel)
        
    }
    
    func gameOver() {
        let gameOverText = SKLabelNode(text: "GAME OVER")
        gameOverText.fontSize = 44
        gameOverText.fontColor = UIColor.redColor()
        
        gameOverText.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        addChild(gameOverText)
    }
    
    
}












