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
#import "BirdsSelection.h"
#import "LevelSelection.h"
#import "GameData.h"
#import "LocalLeaderBoardViewController.h"


#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


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
    
    //**************Cheats for grading (Uncomment to activate)***********************
    [GameData sharedGameData].coinsCollected = 100;
    [GameData sharedGameData].chicksCollected = 100;
    //**************Cheats for grading***********************
    
    appDelegate = [[AppDelegate alloc] init]; //Testing
    _gameVC = [[GameViewController alloc] init];// Testing
  
    [self createIntro];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    }else if ([node.name isEqualToString:@"birds"]){
        
        BirdsSelection *scene = [BirdsSelection unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
    }else if ([node.name isEqualToString:@"levels"]){
        
        LevelSelection *scene = [LevelSelection unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
    }else if ([node.name isEqualToString:@"leaderboard"]){
                
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
            [self showLeaderboardAndAchievements:YES]; //Show Gamecenter leader board if network is availabe, otherwise, show local
        }else{
            [self showLocalLeaderBoard];
        }
        

    }
}

-(void) showLocalLeaderBoard{
    
    LocalLeaderBoardViewController* localLeaderVC = [[LocalLeaderBoardViewController alloc] init];
    UIViewController* vc = self.view.window.rootViewController;
    [vc presentViewController: localLeaderVC animated: YES completion:nil];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = @"leader_1.0"; //Quick Fix, need to change to make it dynamic**
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    UIViewController *vc = self.view.window.rootViewController;
    [vc presentViewController: gcViewController animated: YES completion:nil];
    
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)viewController
{
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
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
    
    SKSpriteNode* selectionBtn = [SKSpriteNode spriteNodeWithImageNamed:@"birdsBtn"];
    [selectionBtn setScale:.3];
    selectionBtn.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height - 50);
    selectionBtn.zPosition = 100;
    selectionBtn.name = @"birds";
    [self addChild:selectionBtn];
    
    SKSpriteNode* levelSelection = [SKSpriteNode spriteNodeWithImageNamed:@"LevelsBtn"];
    [levelSelection setScale:.3];
    levelSelection.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height - 250);
    levelSelection.zPosition = 100;
    levelSelection.name = @"levels";
    [self addChild:levelSelection];
    
    SKSpriteNode* leaderboard = [SKSpriteNode spriteNodeWithImageNamed:@"LevelsBtn"];
    [leaderboard setScale:.3];
    leaderboard.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height - 350);
    leaderboard.zPosition = 100;
    leaderboard.name = @"leaderboard";
    [self addChild:leaderboard];
    
    
    SKSpriteNode* tutorialBtn = [SKSpriteNode spriteNodeWithImageNamed:@"tutorialIcon"];
    [tutorialBtn setScale:.5];
    tutorialBtn.position = CGPointMake(self.size.width /5, self.size.height - 50);
    tutorialBtn.zPosition = 100;
    tutorialBtn.name = @"tutorial";
    [self addChild:tutorialBtn];
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"introPic"];
    [background setScale:[self deviceSize]];
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

#pragma Device Type/Size methods

- (float)deviceSize{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 1.3;
        
    } else {
        return 1.6;
    }
    
    return 0;
}


@end