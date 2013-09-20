//
//  SLMyScene.m
//  ZWar_for_SpriteKit
//
//  Created by bindiry on 13-9-19.
//  Copyright (c) 2013年 bindiry. All rights reserved.
//

#import "SLMyScene.h"
#import <AVFoundation/AVFoundation.h>

@interface SLMyScene()

@property (nonatomic, strong) NSMutableArray *monsters;
@property (nonatomic, strong) NSMutableArray *projectiles;
@property (nonatomic, strong) SKAction *projectileSoundEffectAction;
@property (nonatomic, strong) AVAudioPlayer *bgmPlayer;

@end

@implementation SLMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        // 初始化
        self.monsters = [NSMutableArray array];
        self.projectiles = [NSMutableArray array];
        self.projectileSoundEffectAction = [SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO];
        
        // 1. 设置背景颜色
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2. 创建主角
        SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        
        // 3. 设置主角位置
        player.position = CGPointMake(player.size.width / 2, size.height / 2);
        
        // 4. 添加主角到场景
        [self addChild:player];
        
        // 5. 设置每间隔一秒就添加一个怪物到场景
        SKAction *actionAddMonster = [SKAction runBlock:^{
            [self addMonster];
        }];
        SKAction *actionWaitNextMonster = [SKAction waitForDuration:1];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[actionWaitNextMonster, actionAddMonster]]]];
        
        // 播放背景音乐
        NSString *bgmPath = [[NSBundle mainBundle] pathForResource:@"background-music-aac" ofType:@"caf"];
        self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:bgmPath] error:NULL];
        self.bgmPlayer.numberOfLoops = -1;
        [self.bgmPlayer play];
    }
    return self;
}

- (void) addMonster {
    // 初始化怪物
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // 1. 获取怪物的Y轴随机位置
    CGSize winSize = self.size;
    int minY = monster.size.height / 2;
    int maxY = winSize.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // 2. 设置怪物的坐标在场景右边外侧和一个随机位置并添加到场景
    monster.position = CGPointMake(winSize.width + monster.size.width / 2,
                                   actualY);
    [self addChild:monster];
    
    // 3. 设置怪物从右侧移动到左侧所需要的时间
    // 因为这个时间是随机的，所以怪物的移动会有的快有的慢
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // 4. 设置怪物开始移动，并在移动完成后从场景和怪物列表中移除
    SKAction *actionMove = [SKAction
                            moveTo:CGPointMake(-monster.size.width / 2, actualY)
                            duration:actualDuration];
    SKAction *actionMoveDone = [SKAction runBlock:^{
        [monster removeFromParent];
        [self.monsters removeObject:monster];
    }];
    // 设置动作依次执行
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    // 添加怪物到怪物列表
    [self.monsters addObject:monster];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        // 1. 初始化飞镖并设置位置
        CGSize winSize = self.size;
        SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
        projectile.position = CGPointMake(projectile.size.width / 2, winSize.height / 2);
        
        // 2. 获取触摸点和主角之间的X轴和Y轴距离
        CGPoint location = [touch locationInNode:self];
        CGPoint offset = CGPointMake(location.x - projectile.position.x,
                                     location.y - projectile.position.y);
        
        // 如果距离小于0或为负数就忽略
        if (offset.x <= 0) return;
        // 将飞镖添加到场景
        [self addChild:projectile];
        // 计算飞镖的终点（飞出场景外的坐标）
        int realX = winSize.width + (projectile.size.width / 2);
        float ratio = (float)offset.y / (float)offset.x;
        int realY = (realX * ratio) + projectile.position.y;
        CGPoint realDest = CGPointMake(realX, realY);
        
        // 3. 计算飞镖起始点与终点之前的距离并以此来得出飞镖的移动时间
        int offRealX = realX - projectile.position.x;
        int offRealY = realY - projectile.position.y;
        float length = sqrtf((offRealX * offRealX) + (offRealY * offRealY));
        float velocity = self.size.width / 1;
        float realMoveDuration = length / velocity;
        
        // 4. 设置飞镖移动动作
        SKAction *moveAction = [SKAction moveTo:realDest duration:realMoveDuration];
        // 设置移动动作和音效动作同时执行
        SKAction *projectileCastAction = [SKAction group:@[moveAction, self.projectileSoundEffectAction]];
        // 动作完成后把飞镖从场景和飞镖列表中移除
        [projectile runAction:projectileCastAction completion:^{
            [projectile removeFromParent];
            [self.projectiles removeObject:projectile];
        }];
        // 添加飞镖到飞镖列表
        [self.projectiles addObject:projectile];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // 遍历每个飞镖
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (SKSpriteNode *projectile in self.projectiles) {
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        // 用每个飞镖和所有场景中的怪物们做碰撞检测，如果检测成功，则将当前怪物加入删除列表
        for (SKSpriteNode *monster in self.monsters) {
            if (CGRectIntersectsRect(projectile.frame, monster.frame)) {
                [monstersToDelete addObject:monster];
            }
        }
        // 删除那些在删除列表中的怪物
        for (SKSpriteNode *monster in monstersToDelete)
        {
            [self.monsters removeObject:monster];
            [monster removeFromParent];
        }
        // 如果删除列表中的怪物数大于0，则表示当前这个飞镖碰到了怪物
        // 也需要加入删除列表进行删除
        if (monstersToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
    }
    // 删除那些在删除列表中的飞镖
    for (SKSpriteNode *projectile in projectilesToDelete) {
        [self.projectiles removeObject:projectile];
        [projectile removeFromParent];
    }
}

@end
