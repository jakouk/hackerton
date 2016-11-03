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
    
    SKSpriteNode *_logoLayer;
    
    SKSpriteNode * _background;
    SKSpriteNode *_spaceShip;
    
    SKSpriteNode *_leftWall;
    SKSpriteNode *_rightWall;
    
    SKSpriteNode *_rock1;
    
    NSTimeInterval _rockSpeed;
    NSInteger _rockSpawned;
    
    SKSpriteNode *_scorePoint;
    
    SKLabelNode *_scoreLabelNode;
    SKLabelNode *_bestScoreLabelNode;
    
    NSInteger _score;
    NSInteger _bestScore;
    
    BOOL _isGameOver;
    SKLabelNode *_gameOverLabel;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isGameOver = NO;
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    _movingGameObject = [SKNode node];
    [self addChild:_movingGameObject];
    
    //중력
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    [self creatBackground];
    [self creatLogo];
    
    [self creatSpaceShip];
    
    [self creatWall];
    [self createScore];
    [self createBestScore];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatRock) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(removeLogo) userInfo:nil repeats:NO];

    
//    [self creatRock];
}


- (void)creatLogo{

    SKTexture* gameLogo = [SKTexture textureWithImageNamed:@"startLogo"];
    gameLogo.filteringMode = SKTextureFilteringNearest;
    
    _logoLayer = [SKSpriteNode spriteNodeWithTexture:gameLogo];
    _logoLayer.position = CGPointMake(0, 0);
    [_logoLayer setScale:0.6];
    
    [self addChild:_logoLayer];
}

- (void)removeLogo{

    _logoLayer.hidden = YES;
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
    _spaceShip.physicsBody.restitution = 0.0;
    _spaceShip.zPosition = objectZpositionShip;
    
//    _spaceShip.zPosition =
    _spaceShip.physicsBody.categoryBitMask = OdysseyTypeSpaceShip;
    _spaceShip.physicsBody.collisionBitMask = OdysseyTypeSpaceRock | OdysseyTypeWall;
    _spaceShip.physicsBody.contactTestBitMask = OdysseyTypeSpaceRock | OdysseyTypeSocreLine | OdysseyTypeWall;
    
    
    [_movingGameObject addChild:_spaceShip];
}


// 양 옆 레이아웃 만들기
- (void)creatWall{
    
    _leftWall = [SKSpriteNode node];
    _rightWall = [SKSpriteNode node];
    
    // 왼쪽 벽
    _leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height)];
    _leftWall.position = CGPointMake(-self.frame.size.width/2, CGRectGetMidY(self.frame));
    
    // 오른쪽 벽
    _rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height)];
    _rightWall.position = CGPointMake(self.frame.size.width/2, CGRectGetMidY(self.frame));
    
    _leftWall.physicsBody.dynamic = NO;
    _leftWall.physicsBody.restitution = 0.0;
    _leftWall.zPosition = objectZpositionWall;
    _leftWall.physicsBody.categoryBitMask = OdysseyTypeWall;
    _leftWall.physicsBody.collisionBitMask = OdysseyTypeSpaceShip;
    _leftWall.physicsBody.contactTestBitMask = OdysseyTypeSpaceShip;
    
    _rightWall.physicsBody.dynamic = NO;
    _rightWall.physicsBody.restitution = 0.0;
    _rightWall.zPosition = objectZpositionWall;
    _rightWall.physicsBody.categoryBitMask = OdysseyTypeWall;
    _rightWall.physicsBody.collisionBitMask = OdysseyTypeSpaceShip;
    _rightWall.physicsBody.contactTestBitMask = OdysseyTypeSpaceShip;
    
    [_movingGameObject addChild:_leftWall];
    [_movingGameObject addChild:_rightWall];
}



- (void)creatRock{

    if (_isGameOver == NO) {
    
        SKTexture *rock1Texture = [SKTexture textureWithImageNamed:@"rock"];
        _rock1 = [SKSpriteNode spriteNodeWithTexture:rock1Texture];
        [_rock1 setScale:0.5];
        
        NSInteger temp = (arc4random() % 10000);
        CGFloat x = (CGFloat)temp/10000.f;
        
        CGFloat location = x * (self.frame.size.width/2);
        
        temp = (arc4random() % 10000);
        x = (CGFloat)temp/10000.f;
        
        if (x < 0.5) {
            location = location* -1;
        }else{
            
            location = location - _rock1.frame.size.width;
        }
        
        _rock1.position = CGPointMake(location, self.frame.size.height/2);
        _rock1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_rock1.size.height/2];
        _rock1.physicsBody.dynamic = NO;
        _rock1.physicsBody.categoryBitMask = OdysseyTypeSpaceRock;
        _rock1.physicsBody.contactTestBitMask = OdysseyTypeSpaceShip;
        _rock1.physicsBody.collisionBitMask = OdysseyTypeSpaceShip;
        
        _rock1.zPosition = objectZpositionShip;
        _rockSpeed = 7;
        SKAction *moveRock = [SKAction moveToY:-self.frame.size.height duration:_rockSpeed];
        
        _rockSpawned = 0;
        
        _rockSpawned += 2;
        
        if (_rockSpawned % 10 == 0) {
            _rockSpeed -= 0.5;
        }
        
        SKAction *removeRock = [SKAction removeFromParent];
        SKAction *rockSequence = [SKAction sequence:@[moveRock, removeRock]];
        [_rock1 runAction:rockSequence];
        
        [_movingGameObject addChild:_rock1];
        
        _scorePoint = [SKSpriteNode node];
        //    _scorePoint.position = CGPointMake(-self.frame.size.width/2, _rock1.frame.size.height/2);
        _scorePoint.position = CGPointMake(CGRectGetMidX(self.frame), _rock1.position.y + _rock1.size.height/2);
        _scorePoint.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 1)];
        _scorePoint.physicsBody.dynamic = NO;
        _scorePoint.physicsBody.categoryBitMask = OdysseyTypeSocreLine;
        _scorePoint.physicsBody.contactTestBitMask = OdysseyTypeSpaceShip;
        [_scorePoint runAction:rockSequence];
        [_movingGameObject addChild:_scorePoint];
    
    }
}




- (void)didBeginContact:(SKPhysicsContact *)contact{

    if ([contact.bodyA categoryBitMask] == OdysseyTypeSocreLine  || [contact.bodyB categoryBitMask] == OdysseyTypeSpaceShip) {
        _score += 1;
        _scoreLabelNode.text = [NSString stringWithFormat:@"%ld",_score];
        
    }else{
    
        self.physicsWorld.contactDelegate = nil;
        _movingGameObject.speed = 0;
        
        _isGameOver = YES;
        
        _gameOverLabel = [SKLabelNode node];
        _gameOverLabel.fontName = @"ChalkboardSE-Bold";
        _gameOverLabel.fontSize = 50;
        _gameOverLabel.zPosition = objectZpositionGameOver;
        _gameOverLabel.text = @"Game Over";
        _gameOverLabel.position = CGPointMake(0, 50);
        _gameOverLabel.hidden = NO;
        
        [self addChild:_gameOverLabel];
        
        NSUserDefaults *bestScore = [NSUserDefaults standardUserDefaults];
        
        
        
        if (_score > [[bestScore objectForKey:@"BEST"] integerValue]) {
            [bestScore setObject:[NSString stringWithFormat:@"%ld", _score] forKey:@"BEST"];
        }
        
        
        
    }
    
}

- (void) createScore {
    _scoreLabelNode = [SKLabelNode node];
    _scoreLabelNode.fontColor = [UIColor whiteColor];
    _scoreLabelNode.fontSize = 80;
    _scoreLabelNode.fontName = @"ChalkboardSE-Bold";
    _scoreLabelNode.zPosition =objectZpositionSocre;
    _scoreLabelNode.position = CGPointMake(0, self.frame.size.height/2 - 100);
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld",_score];
    
    [self addChild:_scoreLabelNode];
}

- (void) createBestScore {
    
    NSUserDefaults *bestScore = [NSUserDefaults standardUserDefaults];
    NSString *bestScoreNum = [bestScore objectForKey:@"BEST"];
    
    _bestScoreLabelNode = [SKLabelNode node];
    _bestScoreLabelNode.fontColor = [UIColor whiteColor];
    _bestScoreLabelNode.fontSize = 50;
    _bestScoreLabelNode.fontName = @"ChalkboardSE-Bold";
    _bestScoreLabelNode.zPosition =objectZpositionSocre;
    _bestScoreLabelNode.position = CGPointMake(230, self.frame.size.height/2-100);
    _bestScoreLabelNode.text = [NSString stringWithFormat:@"BEST : %@", bestScoreNum];
    
    [self addChild:_bestScoreLabelNode];
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
    
    if (_isGameOver == YES) {
        
        _isGameOver = NO;
        
        [self isRestart];
        
        
    }
    
}

- (void)isRestart {

    _score = 0;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld",_score];
    
//    [self removeAllChildren];

//    [self didMoveToView:self];
    
//    [self creatSpaceShip];
//    
//    _movingGameObject.speed = 1;
//    
//    _score = 0;
//    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld",_score];
//    _gameOverLabel.hidden = YES;
}















@end
