//
//  SLResultScene.m
//  ZWar_for_SpriteKit
//
//  Created by bindiry on 13-9-20.
//  Copyright (c) 2013年 bindiry. All rights reserved.
//

#import "SLResultScene.h"
#import "SLMyScene.h"

@implementation SLResultScene

- (instancetype)initWithSize:(CGSize)size won:(BOOL)won
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 1. 添加结束文字到场景中
        SKLabelNode *resultLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        resultLabel.text = won ? @"You win!" : @"You lose";
        resultLabel.fontSize = 30;
        resultLabel.fontColor = [SKColor blackColor];
        resultLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:resultLabel];
        
        // 2. 添加重玩文字到场景
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryLabel.text = @"Try again";
        retryLabel.fontSize = 20;
        retryLabel.fontColor = [SKColor blueColor];
        retryLabel.position = CGPointMake(resultLabel.position.x, resultLabel.position.y * 0.8);
        // 为重玩文字添加名称，之后可以通过名称找到这个node
        retryLabel.name = @"retryLabel";
        [self addChild:retryLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        // 获取当前触摸点的node
        CGPoint touchlocation = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchlocation];
        
        // 判断当前node是否是retry文字
        if ([node.name isEqualToString:@"retryLabel"]) {
            [self changeToGameScene];
        }
    }
}

- (void)changeToGameScene {
    SLMyScene *myScene = [SLMyScene sceneWithSize:self.size];
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    [self.scene.view presentScene:myScene transition:reveal];
}

@end
