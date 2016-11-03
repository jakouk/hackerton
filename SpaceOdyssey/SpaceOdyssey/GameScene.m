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
    
    SKTexture* backgroundTexture = [SKTexture textureWithImageNamed:@"bg"];
    SKAction *moveBackground = [SKAction moveByX:0 y:-backgroundTexture.size.width duration:12];
    SKAction *replaceBackground = [SKAction moveByX:0 y:backgroundTexture.size.width duration:0];
    SKAction *backgroundSequence = [SKAction sequence:@[moveBackground,replaceBackground]];
    SKAction *moveBackgroundForever = [SKAction repeatActionForever:backgroundSequence];
    
    for (NSInteger i = 0; i < 2; i+=1) {
        _background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        _background.position = CGPointMake(backgroundTexture.size.width/2 +backgroundTexture.size.width * i, self.frame.size.height/2);
        [_background setSize:CGSizeMake(self.view.frame.size.height, self.view.frame.size.height)];
        [_background runAction:moveBackgroundForever];
        [_movingGameObject addChild:_background];
    }
}


@end
