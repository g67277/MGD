//
//  LevelSelection.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/16/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "LevelSelection.h"
#import "MainMenu.h"
#import "GameScene.h"
#import "Sprites.h"
#import "BirdsSprite.h"
#import "GameData.h"
#import "SpaceLevelSprite.h"

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

@implementation LevelSelection

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
    if ([node.name isEqualToString:@"back"]) {
        
        MainMenu *scene = [MainMenu unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
        //[skView presentScene:scene];
        
    }else{
        NSLog(@"%@", node.name);
        if([node.name isEqualToString:@"Forrest"]){
            [GameData sharedGameData].levelSelected = 1;
            GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:.5]];
        }else if([node.name isEqualToString:@"Space"]){
            if (![GameData sharedGameData].spaceLevelBought) {
                levelSelected = 2;
                [self createAlert:50];
            }else{
                [GameData sharedGameData].levelSelected = 2;
                GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:.5]];
            }
        }
    }
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 0) {//Cancel
        
    }else if (buttonIndex == 1){
        [GameData sharedGameData].coinsCollected -= alertView.tag;
        [GameData sharedGameData].levelSelected = levelSelected;
        [GameData sharedGameData].spaceLevelBought = true;
        spaceLabel.text = @"Space";
        spaceLabel.fontSize = 110;
        coinsCollectedLabel.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].coinsCollected];
    }
    
}

-(void) createAlert:(int) amount{
    
    if (amount > [GameData sharedGameData].coinsCollected) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Insufficient Funds" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Buy?" message:[NSString stringWithFormat:@"Are you sure you want to spend %i coins?", amount] delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes", nil];
        alert.tag = amount;
        [alert show];
    }
    
}
-(void) createIntro{
    
    SKColor* background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    
    self.backgroundColor = background;
    
    coinsCollectedLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    coinsCollectedLabel.fontColor = [UIColor whiteColor];
    coinsCollectedLabel.fontSize = 90;
    coinsCollectedLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 80);
    coinsCollectedLabel.zPosition = 101;
    coinsCollectedLabel.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].coinsCollected];
    [self addChild:coinsCollectedLabel];
    
    SKSpriteNode* forrestNode = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_FORRESTLEVEL];
    forrestNode.position = CGPointMake(CGRectGetMidX(self.frame), 750);
    forrestNode.name = @"Forrest";
    [self addChild:forrestNode];
    
    SKLabelNode* forrestLabel = [SKLabelNode labelNodeWithText:@"Forrest"];
    forrestLabel.position = CGPointMake(CGRectGetMidX(self.frame), 700);
    forrestLabel.fontSize = 110;
    forrestLabel.name = @"Forrest";
    [self addChild:forrestLabel];

    
    SKSpriteNode* spaceNode = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_SPACELEVEL];
    spaceNode.position = CGPointMake(CGRectGetMidX(self.frame), 200);
    spaceNode.name = @"Space";
    [self addChild:spaceNode];
    
    spaceLabel = [SKLabelNode labelNodeWithText:@"Space"];
    spaceLabel.position = CGPointMake(CGRectGetMidX(self.frame), 200);
    spaceLabel.fontSize = 110;
    spaceLabel.name = @"Space";
    if (![GameData sharedGameData].spaceLevelBought) {
        spaceLabel.text = @"50 Coins to Unlock";
        spaceLabel.fontSize = 60;
    }
    [self addChild:spaceLabel];
    
    SKSpriteNode* tutorialBtn = [SKSpriteNode spriteNodeWithImageNamed:@"back"];
    [tutorialBtn setScale:.5];
    tutorialBtn.position = CGPointMake(self.size.width /5, self.size.height - 50);
    tutorialBtn.zPosition = 100;
    tutorialBtn.name = @"back";
    [self addChild:tutorialBtn];
    
    [self initActions];
    
}

-(void) initActions{
    
    //SKAction* repeatScalling = [SKAction sequence:@[[SKAction scaleTo:1.3 duration:0.6], [SKAction scaleTo:1.0 duration:0.6]]];
    
    
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
