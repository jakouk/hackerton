//
//  GameScene.m
//  SpaceGame
//
//  Created by jakouk on 2016. 11. 3..
//  Copyright © 2016년 jakouk. All rights reserved.
//

#import "GameScene.h"

typedef NS_ENUM(NSInteger,Game) {
    GameBackground = 0,
    GameSpace
};



@implementation GameScene {
    
    SKNode *_movingGameObject;
    SKNode *_spaceShip;
    SKSpriteNode * _background;
    SKShapeNode *_spinnyNode;
    SKLabelNode *_label;
}

- (void)didMoveToView:(SKView *)view {
    
    _movingGameObject = [SKNode node];
    [self addChild:_movingGameObject];
    
    SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"spaceBackground"];
    SKAction *moveBackground = [SKAction moveByX:0 y:-backgroundTexture.size.height duration:15];
    SKAction *replaceBackground = [SKAction moveByX:0 y:backgroundTexture.size.height duration:0];
    SKAction *backgroundSequence = [SKAction sequence:@[moveBackground, replaceBackground]];
    SKAction *moveBackgroundForever = [SKAction repeatActionForever:backgroundSequence];
    
    for( NSInteger i = 0; i < 2 + self.frame.size.height / ( backgroundTexture.size.height * 2 ); ++i ) {
        // Create the sprite
        //
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        [sprite setScale:1.0];
//        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
        sprite.position = CGPointMake(0, i * sprite.size.height);
        
        //action이 loop됨.
        [sprite runAction:moveBackgroundForever];
        [_movingGameObject addChild:sprite];
    }
    
    
    
    
//    _background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
//    _background.position = CGPointMake(0 , backgroundTexture.size.height);
//    
//    _background.zPosition = GameBackground;
//    [_background runAction:moveBackgroundForever];
//    [_movingGameObject addChild:_background];
}


@end
