//
//  GameViewController.h
//  UpWard
//

//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController

@property (nonatomic, readonly) NSString* leaderboardIdentifier;
@property (nonatomic, readonly) bool gameCenterEnabled;

-(void)authenticateLocalPlayer;

@end
