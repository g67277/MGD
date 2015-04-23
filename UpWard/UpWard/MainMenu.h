//
//  MainMenu.h
//  UpWard
//
//  Created by Nazir Shuqair on 3/26/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"
#import "GameViewController.h"
@import GameKit;

@interface MainMenu : SKScene <GKGameCenterControllerDelegate>{
    
    SKAction* scallingForever;
    AppDelegate* appDelegate;
    
}

@property (nonatomic) GameViewController* gameVC;

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;

@end
