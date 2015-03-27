//
//  MainMenu.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/26/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "MainMenu.h"
#import "GameScene.h"
#import "LevelSprites.h"
#import "CreditsScene.h"
#import "TutorialScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation MainMenu

-(void)didMoveToView:(SKView *)view {
    
    [self createIntro];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    SKView * skView = (SKView *)self.view;
    
    // if next button touched, start transition to next scene
    if ([node.name isEqualToString:@"playBtn"]) {
        
        GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
        //[skView presentScene:scene];

    }else if ([node.name isEqualToString:@"credits"]){
        
        CreditsScene *scene = [CreditsScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
    }else if ([node.name isEqualToString:@"tutorial"]){
        
        TutorialScene *scene = [TutorialScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
    }
}

-(void) createIntro{
    SKSpriteNode* titleBanner = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_TITLE];
    titleBanner.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height /2 - 5);
    [titleBanner setScale:1.2];
    titleBanner.zPosition = -15;
    [self addChild:titleBanner];
    
    SKSpriteNode* playBtn = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_PLAYBTN];
    playBtn.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height /2.5 -5);
    playBtn.zPosition = 1;
    playBtn.name = @"playBtn";
    [self addChild:playBtn];
    
    SKSpriteNode* creditsBtn = [SKSpriteNode spriteNodeWithImageNamed:@"credits"];
    [creditsBtn setScale:.5];
    creditsBtn.position = CGPointMake(self.size.width - 160, self.size.height - 50);
    creditsBtn.zPosition = 100;
    creditsBtn.name = @"credits";
    [self addChild:creditsBtn];
    
    SKSpriteNode* tutorialBtn = [SKSpriteNode spriteNodeWithImageNamed:@"tutorialIcon"];
    [tutorialBtn setScale:.5];
    tutorialBtn.position = CGPointMake(self.size.width /5, self.size.height - 50);
    tutorialBtn.zPosition = 100;
    tutorialBtn.name = @"tutorial";
    [self addChild:tutorialBtn];
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"introPic"];
    [background setScale:1.3];
    background.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    background.zPosition = -20;
    [self addChild:background];
    
    [self initActions];
    [playBtn runAction:scallingForever];
    
}

-(void) initActions{
    
    SKAction* repeatScalling = [SKAction sequence:@[[SKAction scaleTo:1.3 duration:0.6], [SKAction scaleTo:1.0 duration:0.6]]];
    
    scallingForever = [SKAction repeatActionForever:repeatScalling];
    
}

@end