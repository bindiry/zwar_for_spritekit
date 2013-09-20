//
//  SLViewController.m
//  ZWar_for_SpriteKit
//
//  Created by bindiry on 13-9-19.
//  Copyright (c) 2013年 bindiry. All rights reserved.
//

#import "SLViewController.h"
#import "SLMyScene.h"

@implementation SLViewController

- (void)viewDidAppear:(BOOL)animated
{
    /**
     为了使之后的工作轻松一些，我们可以选择在初始的view显示完成，尺寸通过rotation计算完毕之后再添加新的Scene，这样得到的Scene的尺寸将是宽480（或者568）高320的size。如果在appear之前就使用bounds.size添加的话，将得到宽320 高480（568）的size，会很麻烦。
     所以将ViewController.m中的-viewDidLoad:方法全部替换成下面的-viewDidAppear:。
     */
    [super viewDidAppear:animated];
    
    // Configure the view
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene
    SKScene *scene = [SLMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
