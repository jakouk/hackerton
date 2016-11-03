//
//  GameScene.m
//  SpaceGame
//
//  Created by jakouk on 2016. 11. 3..
//  Copyright © 2016년 jakouk. All rights reserved.
//

#import "GameScene.h"

typedef NS_OPTIONS(uint32_t, OdysseyType) {
    OdysseyTypeBackground = 1 << 0,
    OdysseyTypeSpaceRock = 1 << 1,
    OdysseyTypeSpaceShip = 1 << 2,
    OdysseyTypeWall = 1 << 3,
    OdysseyTypeSocreLine = 1 << 4,
};

typedef NS_ENUM(NSInteger, objectZposition) {

    objectZpositionBackground = 0,
    objectZpositionWall,
    objectZpositionRock,
    objectZpositionShip,
    objectZpositionSocre,
    objectZpositionGameOver
};


@interface GameScene () <SKPhysicsContactDelegate>

@end

@implementation GameScene {
    
    SKNode *_movingGameObject;
    
    SKSpriteNode * _background;
    SKSpriteNode *_spaceShip;
    
    SKSpriteNode *_leftWall;
    SKSpriteNode *_rightWall;
}

- (void)didMoveToView:(SKView *)view {
    
    _movingGameObject = [SKNode node];
    [self addChild:_movingGameObject];
    
    //중력
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    [self creatBackground];
    [self creatSpaceShip];
    
    [self creatWall];
    
    NSLog(@"frame %lf", self.frame.size.height);
    NSLog(@"view %lf", self.view.frame.size.height);
    
    NSLog(@"frame %lf", self.frame.size.width);
    NSLog(@"view %lf", self.view.frame.size.width);
    
}


// 배경 만들기 메소드
- (void)creatBackground{
    SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"spaceBackground"];
    SKAction *moveBackground = [SKAction moveByX:0 y:-backgroundTexture.size.height duration:50];
    SKAction *replaceBackground = [SKAction moveByX:0 y:backgroundTexture.size.height duration:0];
    SKAction *backgroundSequence = [SKAction sequence:@[moveBackground, replaceBackground]];
    SKAction *moveBackgroundForever = [SKAction repeatActionForever:backgroundSequence];
    

    for( NSInteger i = 0; i < 2 + self.frame.size.height / ( backgroundTexture.size.height * 2 ); ++i ) {

        // Create the sprite
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        [sprite setScale:1.0];
        sprite.position = CGPointMake(0, i * sprite.size.height);
        sprite.zPosition = objectZpositionBackground;
        //action이 loop됨.
        [sprite runAction:moveBackgroundForever];
        [_movingGameObject addChild:sprite];
    }
}


// 우주선 만들기 메소드
- (void)creatSpaceShip{

    SKTexture* shipTexture = [SKTexture textureWithImageNamed:@"SpaceShip"];
    shipTexture.filteringMode = SKTextureFilteringNearest;
    
    
    //우주선 생성
    _spaceShip = [SKSpriteNode spriteNodeWithTexture:shipTexture];
    [_spaceShip setScale:0.2];
    
    
    //우주선 위치 고정
    _spaceShip.position = CGPointMake(0, -self.frame.size.height/4);
    
    
    //물리적인 몸체 주기
    _spaceShip.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_spaceShip.size.height / 2];
    _spaceShip.physicsBody.dynamic = YES;
    _spaceShip.physicsBody.allowsRotation = NO;
    _spaceShip.zPosition = objectZpositionShip;
    
//    _spaceShip.zPosition =
    _spaceShip.physicsBody.categoryBitMask = OdysseyTypeSpaceShip;
    _spaceShip.physicsBody.collisionBitMask = OdysseyTypeSpaceRock | OdysseyTypeWall;
    _spaceShip.physicsBody.contactTestBitMask = OdysseyTypeSpaceRock | OdysseyTypeSocreLine | OdysseyTypeWall;
    
    
    [_movingGameObject addChild:_spaceShip];
}


// 양 옆 레이아웃 만들기
- (void)creatWall{

//    SKTexture* wallTexture = [SKTexture textureWithImageNamed:@"wall"];
//    wallTexture.filteringMode = SKTextureFilteringNearest;
//    
//    
//    //우주선 생성
//    _leftWall = [SKSpriteNode spriteNodeWithTexture:wallTexture];
//    _rightWall = [SKSpriteNode spriteNodeWithTexture:wallTexture];
    
    _leftWall = [SKSpriteNode node];
    _rightWall = [SKSpriteNode node];
    
    // 왼쪽 벽
    _leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height)];
    _leftWall.position = CGPointMake(-self.frame.size.width/2, CGRectGetMidY(self.frame));
    
    // 오른쪽 벽
    _rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height)];
    _rightWall.position = CGPointMake(self.frame.size.width/2, CGRectGetMidY(self.frame));
    
    _leftWall.physicsBody.dynamic = NO;
    _leftWall.zPosition = objectZpositionWall;
    _leftWall.physicsBody.categoryBitMask = OdysseyTypeWall;
    _leftWall.physicsBody.collisionBitMask = OdysseyTypeSpaceShip;
    _leftWall.physicsBody.contactTestBitMask = OdysseyTypeSpaceShip;
    
    _rightWall.physicsBody.dynamic = NO;
    _rightWall.zPosition = objectZpositionWall;
    _rightWall.physicsBody.categoryBitMask = OdysseyTypeWall;
    _rightWall.physicsBody.collisionBitMask = OdysseyTypeSpaceShip;
    _rightWall.physicsBody.contactTestBitMask = OdysseyTypeSpaceShip;
    
    [self addChild:_leftWall];
    [self addChild:_rightWall];
}


- (void)didBeginContact:(SKPhysicsContact *)contact{

    NSLog(@"쾅");
}


// 터치 이벤트 메소드
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

//    NSArray *touchArray = [touches allObjects];
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    if (touchLocation.x < CGRectGetMidX(self.view.frame)) {
        
//        CGFloat leftDistanceToMove = self.frame.size.width;
//        SKAction *moveLeft = [SKAction moveToX:leftDistanceToMove duration:1];

        _spaceShip.physicsBody.velocity = CGVectorMake(0, 0);
        [_spaceShip.physicsBody applyImpulse:CGVectorMake(-80, 0)];
        
    }else{
        
        _spaceShip.physicsBody.velocity = CGVectorMake(0, 0);
        [_spaceShip.physicsBody applyImpulse:CGVectorMake(80, 0)];
    }
    
}















@end
