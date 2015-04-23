//
//  BirdsSelection.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//
//

#import "MainMenu.h"
#import "GameScene.h"
#import "BirdsSelection.h"
#import "Sprites.h"
#import "BirdsSprite.h"
#import "GameData.h"
#import "Outfits.h"

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

@implementation BirdsSelection

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
        
        Outfits *scene = [Outfits unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        if([node.name isEqualToString:@"ella"]){
            [GameData sharedGameData].birdSelected = 1;
            [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:.5]];
        }else if([node.name isEqualToString:@"dex"]){
            if (![GameData sharedGameData].dexBought) {
                birdSelected = 2;
                [self createAlert:10];
                //update label
            }else{
                [GameData sharedGameData].birdSelected = 2;
                [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:.5]];
            }
        }else if([node.name isEqualToString:@"herb"]){
            if (![GameData sharedGameData].herbBought) {
                birdSelected = 3;
                [self createAlert:15];
                //update label
            }else{
                [GameData sharedGameData].birdSelected = 3;
                [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:.5]];
            }
        }
        [[GameData sharedGameData] save];

    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 0) {//Cancel
        
    }else if (buttonIndex == 1){
        [GameData sharedGameData].chicksCollected -= alertView.tag;
        [GameData sharedGameData].birdSelected = birdSelected;
        if (birdSelected == 2) {
            [GameData sharedGameData].dexBought = true;
            dexLabel.text = @"Dex";
            dexLabel.fontSize = 90;
        }else if(birdSelected == 3){
            [GameData sharedGameData].herbBought = true;
            herbLabel.text = @"Herb";
            herbLabel.fontSize = 90;
        }
        NSLog(@"%d", [GameData sharedGameData].dexBought);

        chicksCountLabel.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].chicksCollected];
        [[GameData sharedGameData] save];
    }
    
}

-(void) createAlert:(int) amount{
    
    if (amount > [GameData sharedGameData].chicksCollected) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Chicks" message:@"Save more chicks to unlock this bird" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Buy?" message:[NSString stringWithFormat:@"Are you sure you want to spend %i chicks?", amount] delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes", nil];
        alert.tag = amount;
        [alert show];
    }
    
}


-(void) createIntro{
    
    SKColor* background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];

    self.backgroundColor = background;
    
    SKNode* ellaNode = [SKNode node];
    ellaNode.position = CGPointMake(CGRectGetMidX(self.frame) / 1.6, 800);
    ellaNode.name = @"ella";
    
    SKSpriteNode* ella = [SKSpriteNode spriteNodeWithTexture:SPRITES_TEX_ELLA];
    [ella setScale:3];
    ella.position = CGPointMake(0, 0);
    ella.name = @"ella";
    [ellaNode addChild:ella];
    
    SKLabelNode* ellaLabel = [SKLabelNode labelNodeWithText:@"Ella"];
    ellaLabel.position = CGPointMake(ella.size.width + 30, -40);
    ellaLabel.fontName = @"AppleSDGothicNeo-Bold";
    ellaLabel.fontSize = 90;
    ellaLabel.name = @"ella";
    [ellaNode addChild:ellaLabel];
    
    [self addChild:ellaNode];
    
    SKNode* dexNode = [SKNode node];
    dexNode.position = CGPointMake(CGRectGetMidX(self.frame) / 1.6, ellaNode.position.y - 300);
    dexNode.name = @"dex";
    
    SKSpriteNode* dex = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_DEX];
    [dex setScale:.5];
    dex.position = CGPointMake(0, 20);
    dex.name = @"dex";
    [dexNode addChild:dex];
    
    dexLabel = [SKLabelNode labelNodeWithText:@"Dex"];
    dexLabel.position = CGPointMake(ella.size.width + 30, 0);
    dexLabel.fontName = @"AppleSDGothicNeo-Bold";
    dexLabel.fontSize = 90;
    dexLabel.name = @"dex";
    if (![GameData sharedGameData].dexBought) {
        dexLabel.text = @"10 Chicks";
        dexLabel.fontSize = 40;
    }
    [dexNode addChild:dexLabel];
    
    [self addChild:dexNode];
    
    SKNode* herbNode = [SKNode node];
    herbNode.position = CGPointMake(CGRectGetMidX(self.frame) / 1.6, dexNode.position.y - 300);
    herbNode.name = @"herb";
    
    SKSpriteNode* herb = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HERB];
    [herb setScale:.5];
    herb.position = CGPointMake(0, 20);
    herb.name = @"herb";
    [herbNode addChild:herb];
    
    herbLabel = [SKLabelNode labelNodeWithText:@"Herb"];
    herbLabel.position = CGPointMake(ella.size.width + 30, 0);
    herbLabel.fontName = @"AppleSDGothicNeo-Bold";
    herbLabel.fontSize = 90;
    herbLabel.name = @"herb";
    if (![GameData sharedGameData].herbBought) {
        herbLabel.text = @"15 Chicks";
        herbLabel.fontSize = 40;
    }
    [herbNode addChild:herbLabel];
    
    [self addChild:herbNode];
    
    chicksCountLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%li", [GameData sharedGameData].chicksCollected]];
    chicksCountLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height - 90);
    chicksCountLabel.zPosition = 101;
    chicksCountLabel.fontName = @"AppleSDGothicNeo-Bold";
    chicksCountLabel.fontSize = 70;
    [self addChild:chicksCountLabel];
    
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
