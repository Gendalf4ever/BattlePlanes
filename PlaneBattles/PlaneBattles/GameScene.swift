//
//  GameScene.swift
//  PlaneBattles
//
//  Created by Master on 30/03/2020.
//  Copyright © 2020 Master. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
class GameScene: SKScene, SKPhysicsContactDelegate {
    var battleField:SKEmitterNode! //for animation
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int=0 {
        didSet{
            scoreLabel.text="Самолетов сбито: \(score)"
        }
    }
    var gameTimer:Timer!
    var enemyPlanes=["EnemyPlane","EnemyPlane2","EnemyPlane3"]
    let planeCategory:UInt32 = 0x1<<1 //для создания уникального идентификатора
     let shootCategory:UInt32 = 0x1<<0
    let motionManager=CMMotionManager()
    var accAnglex:CGFloat=0
    override func didMove(to view: SKView) {
        
       // battleField=SKEmitterNode(fileNamed: <#T##String#>)
        player=SKSpriteNode(imageNamed: "Plane")
        player.position=CGPoint(x:0,y:-350)
        self.addChild(player)
        self.physicsWorld.gravity=CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate=self //для отслеживания соприкосновений
        scoreLabel = SKLabelNode(text: "Самолетов сбито: 0")
        scoreLabel.fontName="AmericanTypewriter"
        scoreLabel.fontSize=36
        scoreLabel.color=UIColor.white
        //scoreLabel.position=CGPoint(x: -200, y: self.frame.size.height-60)
        scoreLabel.position=CGPoint(x: -100, y: 500)
        score=0
        self.addChild(scoreLabel)
        gameTimer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addEnemyPlane), userInfo: nil, repeats: true)
        motionManager.accelerometerUpdateInterval=0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accData = data{
                let accelerattion=accData.acceleration
                self.accAnglex = CGFloat(accelerattion.x)*0.75+self.accAnglex*0.25
            } //if
        }//motionManager
        }//func
    override func didSimulatePhysics() {
        player.position.x+=accAnglex*50
        if player.position.x < -350{
            player.position=CGPoint(x: 350, y: player.position.y)
        }//if
        else if player.position.x > 350{
                  player.position=CGPoint(x: -350, y: player.position.y)
        }//else if
        
    }
     @objc func addEnemyPlane(){
        enemyPlanes=GKRandomSource.sharedRandom().arrayByShufflingObjects(in: enemyPlanes) as! [String]
        let plane = SKSpriteNode(imageNamed: enemyPlanes[0])
        let enemyposition = GKRandomDistribution(lowestValue: -280, highestValue: 280)
        let position = CGFloat(enemyposition.nextInt())
        plane.position=CGPoint(x: position, y: 800)
//        plane.setScale(2)
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic=true
        plane.physicsBody?.categoryBitMask=planeCategory
        plane.physicsBody?.contactTestBitMask=shootCategory
        plane.physicsBody?.collisionBitMask=0
        self.addChild(plane)
        let animationSpeed:TimeInterval=6
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: position, y: -800), duration: animationSpeed))
        actions.append(SKAction.removeFromParent())
        plane.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        shoot()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var planeBody:SKPhysicsBody
        var shootBody:SKPhysicsBody
        if contact.bodyA.categoryBitMask<contact.bodyB.categoryBitMask{
            
            shootBody=contact.bodyA
            planeBody=contact.bodyB
        }
        else {
            planeBody=contact.bodyA
            shootBody=contact.bodyB
        }
  
        if (planeBody.categoryBitMask & planeCategory) != 0 && (shootBody.categoryBitMask & shootCategory) != 0 {
            collisionElements(shootNode: shootBody.node as! SKSpriteNode, planeNode: planeBody.node as! SKSpriteNode)
        }
    }
    
    func collisionElements(shootNode:SKSpriteNode,planeNode:SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "Explosion.sks")
        explosion?.position=planeNode.position
        self.addChild(explosion!)
        //звук взрыва добавь
        shootNode.removeFromParent()
        planeNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 2))
        explosion?.removeFromParent()
        score+=1
    }
    
    func shoot(){
        self.run(SKAction.playSoundFileNamed("Shoot.mp3", waitForCompletion: false))
        let bullet = SKSpriteNode(imageNamed: "LightShoot")
        bullet.position=player.position
        bullet.position.y+=5
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
         bullet.physicsBody?.isDynamic=true
         bullet.physicsBody?.categoryBitMask=shootCategory
         bullet.physicsBody?.contactTestBitMask=planeCategory
         bullet.physicsBody?.collisionBitMask=0
        bullet.physicsBody?.usesPreciseCollisionDetection=true
         self.addChild(bullet)
        let animationSpeed:TimeInterval=0.4
         var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x:player.position.x, y: 800), duration: animationSpeed))
         actions.append(SKAction.removeFromParent())
         bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
