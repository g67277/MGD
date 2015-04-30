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
#include<unistd.h>
#include<netdb.h>


#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

//Need to find a better way for this method
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
  
    [self createIntro];  // Creates main screen intro
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"] || ![self isNetworkAvailable]) {
        [self welcomeMessage]; // If user is not logged in, or if there is no connection, show the welcome message
    }else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"] && [self isNetworkAvailable]){
        [self syncScores];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self]; // location of the touch
    SKNode *node = [self nodeAtPoint:location];  // node touched
    SKView * skView = (SKView *)self.view; // current skview
    
    
    
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
                
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"] && [self isNetworkAvailable]) {
            [self showLeaderboardAndAchievements:YES]; //Show Gamecenter leaderboard if network is availabe, otherwise, show local
        }else{
            [self showLocalLeaderBoard];
        }
    }else if ([node.name isEqualToString:@"change"]){

        [self showAlertWithTextField];  // Display alertview with uitextfield for name input
        
    }else if([node.name isEqualToString:@"clearAchievement"]){
        [self resetAchievements];
    }
}

-(void)showAlertWithTextField{  // Display alertview with uitextfield for name input
    
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [dialog show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
        [[NSUserDefaults standardUserDefaults] setValue:[[alertView textFieldAtIndex:0] text] forKey:@"username"];
        name.text = [NSString stringWithFormat:@"Welcome back %@", [[alertView textFieldAtIndex:0] text]];
}

-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
}

-(void) syncScores{
    
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]) {
        NSMutableArray* sortedScores = [[NSMutableArray alloc] init];
        incomingScores = [self decodeData:[[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]];
        
        for (ScoreData* scoreData in incomingScores){
            if ([scoreData.alies isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"gcalies"]]) {
                [sortedScores addObject:scoreData];
            }
        }
        
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        [sortedScores sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
        [incomingScores removeAllObjects];
        incomingScores = sortedScores;
        if (incomingScores[0]) {
            ScoreData* scoreData = incomingScores[0];
            GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier: @"leader_1.0"];
            if ([scoreData.alies isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"gcalies"]]) {
                score.value = scoreData.score; // push highscore to GC
                [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                }];
            }
        }
    }
    
}

- (NSMutableArray*) decodeData: (NSMutableArray*) encodedArray{
    
    NSMutableArray* decodedObjects = [[NSMutableArray alloc] init];
    ScoreData* scoreData = [[ScoreData alloc] init];
    for (int i = 0; i < encodedArray.count; i++) {
        scoreData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedArray[i]];
        [decodedObjects addObject:scoreData];
    }
    return decodedObjects;
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
    
    SKSpriteNode* leaderboard = [SKSpriteNode spriteNodeWithImageNamed:@"leaderboard"];
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
    
    //Debugging only***
    SKSpriteNode* clearAchievement = [SKSpriteNode spriteNodeWithImageNamed:@"tutorialIcon"];
    [clearAchievement setScale:.5];
    clearAchievement.position = CGPointMake(self.size.width /5, self.size.height - 250);
    clearAchievement.zPosition = 100;
    clearAchievement.name = @"clearAchievement";
    [self addChild:clearAchievement];
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"introPic"];
    [background setScale:[self deviceSize]];
    background.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    background.zPosition = -20;
    [self addChild:background];
    
    [self initActions];
    [playBtn runAction:scallingForever];
    
}

-(void) welcomeMessage{
    
    SKSpriteNode* footerBG = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.size.width, 100)];
    footerBG.alpha = .9;
    footerBG.position = CGPointMake(CGRectGetMidX(self.frame), -10);
    footerBG.zPosition = 50;
    [self addChild:footerBG];
    
    name = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
    name.fontColor = [UIColor darkGrayColor];
    name.fontSize = 28;
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"username"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"Player" forKey:@"username"];
    }
    name.text = [NSString stringWithFormat:@"Welcome back %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
    name.position = CGPointMake(-100, -10);
    [footerBG addChild:name];
    
    SKSpriteNode* changeBG = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:CGSizeMake(130, footerBG.size.height)];
    changeBG.alpha = .4;
    changeBG.position = CGPointMake(225, 0);
    changeBG.zPosition = 10;
    changeBG.name = @"change";
    [footerBG addChild:changeBG];
    
    SKLabelNode* changeName = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
    changeName.fontSize = 20;
    changeName.fontColor = [UIColor blueColor];
    changeName.text = @"Change";
    changeName.position = CGPointMake(220, -10);
    changeName.zPosition = 20;
    changeName.name = @"change";
    [footerBG addChild:changeName];
    
    SKAction* moveFooterUP = [SKAction moveByX:0 y:footerBG.size.height duration:.3];
    moveFooterUP.timingMode = SKActionTimingEaseOut;
    SKAction* moveDownBounce = [SKAction moveByX:0 y:-footerBG.size.height / 2 duration:.3];
    moveDownBounce.timingMode = SKActionTimingEaseOut;
    SKAction* sequence = [SKAction sequence:@[moveFooterUP, moveDownBounce]];
    [footerBG runAction:sequence];
    
    
}

-(void) initActions{
    
    SKAction* repeatScalling = [SKAction sequence:@[[SKAction scaleTo:1.3 duration:0.6], [SKAction scaleTo:1.0 duration:0.6]]];
    
    scallingForever = [SKAction repeatActionForever:repeatScalling];
    
}

//for debugging only, take out before release*******
-(void)resetAchievements{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
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