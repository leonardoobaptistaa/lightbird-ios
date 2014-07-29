//
//  GameScene.swift
//  LightBird
//
//  Created by Leonardo Baptista on 6/7/14.
//  Copyright (c) 2014 Ruppy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let bird : SKSpriteNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(50, 50));
    let upperObstacle : SKSpriteNode = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(50, 1000));
    let lowerObstacle : SKSpriteNode = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(50, 1000));
    
    var spacing : Int = 200
    let minimunSpace : Int = 120
    
    var screenHeight : Float = 0.0
    var screenWidth : Float = 0.0
    let percentageOffScreen : Float = 0.2
    var availableScreen : UInt32 = 0
    var topMargin : Float = 0.0
    
    let lblScore = SKLabelNode(fontNamed:"Chalkduster")
    var score = 0
    var lastTime : CFTimeInterval = 0
    var enabled = false
    
    func Start() {
        upperObstacle.physicsBody = nil
        lowerObstacle.physicsBody = nil
        bird.physicsBody = nil
        
        enabled = false
        bird.position = CGPointMake(CGFloat(80), CGFloat(screenHeight/2.0))
        score = -1
        updateScore()
        spacing = 200
        respaw()
        
        upperObstacle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(50, CGFloat(screenHeight)))
        upperObstacle.physicsBody.affectedByGravity = false
        upperObstacle.physicsBody.mass = 1;
        upperObstacle.physicsBody.allowsRotation = false
        upperObstacle.physicsBody.contactTestBitMask = 1
        
        lowerObstacle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(50, CGFloat(screenHeight)))
        lowerObstacle.physicsBody.affectedByGravity = false
        lowerObstacle.physicsBody.mass = 1;
        lowerObstacle.physicsBody.allowsRotation = false
        lowerObstacle.physicsBody.contactTestBitMask = 1
        
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(50, 50))
        bird.physicsBody.affectedByGravity = false
        bird.physicsBody.mass = 0.9;
        bird.physicsBody.friction = 10
        bird.physicsBody.contactTestBitMask = 1
    }
    
    func Initialize() {
        self.physicsWorld.contactDelegate = self
        screenHeight = Float(UIScreen.mainScreen().bounds.height)
        screenWidth = Float(UIScreen.mainScreen().bounds.width)
        
        bird.anchorPoint = CGPointMake(0.5, 0.5)
        self.addChild(bird)
        
        upperObstacle.size.height = CGFloat(screenHeight)
        upperObstacle.anchorPoint = CGPointMake(0.5, 0.5)
        self.addChild(upperObstacle)
        
        lowerObstacle.size.height = CGFloat(screenHeight)
        lowerObstacle.anchorPoint = CGPointMake(0.5, 0.5)
        self.addChild(lowerObstacle)
        
        topMargin = screenHeight * percentageOffScreen
        availableScreen = UInt32(screenHeight - (topMargin * 2.0))
        
        lblScore.horizontalAlignmentMode = .Right
        lblScore.verticalAlignmentMode = .Top
        lblScore.fontColor = UIColor.blackColor()
        lblScore.text = "0";
        lblScore.fontSize = 40;
        lblScore.position = CGPoint(x:CGRectGetWidth(self.frame) - 5, y: CGRectGetHeight(self.frame) - 30);
        
        self.addChild(lblScore)
    }
    
    override func didMoveToView(view: SKView) {
        Initialize()
        Start()
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
        var velocity = bird.physicsBody.velocity
        bird.physicsBody.applyImpulse(CGVectorMake(0, -bird.physicsBody.velocity.dy))
        bird.physicsBody.applyImpulse(CGVectorMake(0, 250))
        if (enabled == false) {
            bird.physicsBody.affectedByGravity = true
            enabled = true;
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (enabled == false) {
            lastTime = currentTime
            return;
        }
        let dtime : Float = Float(currentTime - lastTime)
        let force : Float = Float(-500) * dtime
        let forceVector = CGVectorMake(CGFloat(force), 0)
        
        upperObstacle.physicsBody.applyForce(forceVector)
        lowerObstacle.physicsBody.applyForce(forceVector)
        
        if (shouldRespaw()) {
            respaw()
            updateScore()
        }
        lastTime = currentTime
    }
    
    func shouldRespaw() -> Bool {
        return upperObstacle.position.x < -upperObstacle.size.width;
    }
    
    func respaw() {
        spacing = spacing - 2;
        spacing = max(spacing, minimunSpace)
        
        var topRandomPosition : Int = Int(arc4random_uniform(availableScreen)) + Int(topMargin * 2) + Int(upperObstacle.size.height/2)
        var bottomRandomPosition = topRandomPosition - spacing - Int(lowerObstacle.size.height/2) - Int(upperObstacle.size.height/2)
    
        upperObstacle.zRotation = 0
        upperObstacle.position.x = CGFloat(screenWidth) + CGFloat(upperObstacle.size.width/2)
        upperObstacle.position.y = CGFloat(topRandomPosition)
        
        lowerObstacle.zRotation = 0
        lowerObstacle.position.x = CGFloat(screenWidth) + CGFloat(lowerObstacle.size.width/2)
        lowerObstacle.position.y = CGFloat(bottomRandomPosition)
    }
    
    func updateScore() {
        score = score + 1
        lblScore.text = "\(score)"
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        Start()
    }

}
