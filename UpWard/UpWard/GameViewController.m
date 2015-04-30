//
//  GameViewController.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/2/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "GameViewController.h"
#import "MainMenu.h"
@import GameKit;

@interface GameViewController()

@end

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

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self authenticateLocalPlayer];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    MainMenu *menuScene = [MainMenu unarchiveFromFile:@"GameScene"];
    menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:menuScene];
    
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer]; //Creates GKplayer object
        
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){ // Starts authenticating
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil]; // if player is not already signed in, display the controller so they can log into game center
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES; //User is logged in
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"loggedIn"]; // save the log in state
                [[NSUserDefaults standardUserDefaults] setValue:[GKLocalPlayer localPlayer].alias forKey:@"username"]; // save entered username
                [[NSUserDefaults standardUserDefaults] setValue:[GKLocalPlayer localPlayer].alias forKey:@"gcalies"]; // save game center alies
                
            }else{
                _gameCenterEnabled = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"loggedIn"];
                [[NSUserDefaults standardUserDefaults] setValue:@"player" forKey:@"username"];
            }
        }
    };
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
