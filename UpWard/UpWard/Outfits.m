//
//  Outfits.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "Outfits.h"
#import "GameScene.h"
#import "BirdsSelection.h"
#import "Sprites.h"
#import "BirdsSprite.h"
#import "GameData.h"
#import "LevelSprites.h"
@import GameKit;

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

@implementation Outfits

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
        
        BirdsSelection *scene = [BirdsSelection unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
        //[skView presentScene:scene];
        
    }else if([node.name isEqualToString:@"start"]){
        GameScene * scene = [GameScene unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration:.5]];
    }else if ([node.name isEqualToString:@"clear"]){
        [GameData sharedGameData].accessorySelected = 0;
        [bird removeAllChildren];
        birdLabel.text = birdName;
        birdLabel.fontSize = 110;
    }else if([node.name isEqualToString:@"greenGlass"]){
        if (![GameData sharedGameData].greenBought) {
            accessorySelected = 1;
            [self createAlert:20];
        }else{
            accessorySelected = 1;
            [GameData sharedGameData].accessorySelected = 1;
            [self mergeTextures:1];
        }
    }else if([node.name isEqualToString:@"purpleGlass"]){
        if (![GameData sharedGameData].purpleBought) {
            accessorySelected = 2;
            [self createAlert:25];
        }else{
            accessorySelected = 2;
            [GameData sharedGameData].accessorySelected = 2;
            [self mergeTextures:2];
        }
        
    }else if([node.name isEqualToString:@"redGlass"]){
        if (![GameData sharedGameData].redBought) {
            accessorySelected = 3;
            [self createAlert:30];
        }else{
            accessorySelected = 3;
            [GameData sharedGameData].accessorySelected = 3;
            [self mergeTextures:3];
        }
    }else if([node.name isEqualToString:@"mustach"]){
        if (![GameData sharedGameData].mustachBought) {
            accessorySelected = 4;
            [self createAlert:50];
        }else{
            accessorySelected = 4;
            [GameData sharedGameData].accessorySelected = 4;
            [self mergeTextures:4];
        }
    }else if([node.name isEqualToString:@"fancyGlass"]){
        if (![GameData sharedGameData].fancyBought) {
            accessorySelected = 5;
            [self createAlert:40];
        }else{
            accessorySelected = 5;
            [GameData sharedGameData].accessorySelected = 5;
            [self mergeTextures:5];
        }
        
    }else if([node.name isEqualToString:@"helmet"]){
        NSLog(@"%hhu", [GameData sharedGameData].helmetBought);
        if (![GameData sharedGameData].helmetBought) {
            accessorySelected = 6;
            [self createAlert:10];
        }else{
            accessorySelected = 6;
            [GameData sharedGameData].accessorySelected = 6;
            [self mergeTextures:6];
        }
        
    }
    [[GameData sharedGameData] save];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 0) {//Cancel
        
    }else if (buttonIndex == 1){
        [GameData sharedGameData].coinsCollected -= alertView.tag;
        [GameData sharedGameData].accessorySelected = accessorySelected;
        [self mergeTextures:accessorySelected];
        currentCoin.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].coinsCollected];
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
    
    birdSelected = [GameData sharedGameData].birdSelected;
    
    if (birdSelected == 1) {
        birdTexture = SPRITES_TEX_ELLA;
        birdName = @"Ella";
        scale = 4;
    }else if(birdSelected == 2){
        birdTexture = BIRDSSPRITE_TEX_DEX;
        birdName = @"Dex";
        scale = .6;
    }else if (birdSelected == 3){
        birdTexture = BIRDSSPRITE_TEX_HERB;
        birdName = @"Herb";
        scale = .6;
    }
    
    bird = [SKSpriteNode spriteNodeWithTexture:birdTexture];
    [bird setScale:scale];
    bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 250);
    [self addChild:bird];
    
    birdLabel = [SKLabelNode labelNodeWithText:birdName];
    birdLabel.position = CGPointMake(CGRectGetMidX(self.frame), bird.position.y -250);
    birdLabel.fontName = @"AppleSDGothicNeo-Bold";
    birdLabel.fontSize = 110;
    [self addChild:birdLabel];

    currentCoin = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%ld", [GameData sharedGameData].coinsCollected]];
    currentCoin.position = CGPointMake(160, bird.position.y);
    currentCoin.fontName = @"AppleSDGothicNeo-Bold";
    currentCoin.fontSize = 70;
    currentCoin.fontColor = [UIColor yellowColor];
    [self addChild:currentCoin];
    
    SKSpriteNode* tutorialBtn = [SKSpriteNode spriteNodeWithImageNamed:@"back"];
    [tutorialBtn setScale:.5];
    tutorialBtn.position = CGPointMake(self.size.width /5, self.size.height - 50);
    tutorialBtn.zPosition = 100;
    tutorialBtn.name = @"back";
    [self addChild:tutorialBtn];
    
    SKSpriteNode* playBtn = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_PLAYBTN];
    [playBtn setScale:.5];
    playBtn.position = CGPointMake(self.size.width - 160, self.size.height - 50);
    playBtn.zPosition = 100;
    playBtn.name = @"start";
    [self addChild:playBtn];
    
    SKSpriteNode* clearBtn = [SKSpriteNode spriteNodeWithImageNamed:@"cancelbtn"];
    [clearBtn setScale:.3];
    clearBtn.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height - 50);
    clearBtn.zPosition = 100;
    clearBtn.name = @"clear";
    [self addChild:clearBtn];
    
    [self createStore];
    
    [self initActions];
    
}

-(void) createStore{
    
    SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
    [greenGlass setScale:2.2];
    greenGlass.position = CGPointMake(self.size.width / 3.8, 400);
    greenGlass.name = @"greenGlass";
    [self addChild:greenGlass];
    
    SKLabelNode* greenPrice = [SKLabelNode labelNodeWithText:@"20 Coins"];
    greenPrice.position = CGPointMake(0, -40);
    greenPrice.fontColor = [UIColor yellowColor];
    greenPrice.fontName = @"AppleSDGothicNeo-Bold";
    greenPrice.fontSize = 15;
    if ([GameData sharedGameData].greenBought) {
        greenPrice.text = @"Purchased!";
    }
    [greenGlass addChild:greenPrice];
    
    SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
    [purpleGlass setScale:2.2];
    purpleGlass.position = CGPointMake(greenGlass.position.x + greenGlass.size.width + 30, 400);
    purpleGlass.name = @"purpleGlass";
    [self addChild:purpleGlass];
    
    SKLabelNode* purplePrice = [SKLabelNode labelNodeWithText:@"25 Coins"];
    purplePrice.position = CGPointMake(0, -40);
    purplePrice.fontColor = [UIColor yellowColor];
    purplePrice.fontName = @"AppleSDGothicNeo-Bold";
    purplePrice.fontSize = 15;
    if ([GameData sharedGameData].purpleBought) {
        purplePrice.text = @"Purchased!";
    }
    [purpleGlass addChild:purplePrice];
    
    SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
    [redGlass setScale:2.2];
    redGlass.position = CGPointMake(purpleGlass.position.x + purpleGlass.size.width + 30, 400);
    redGlass.name = @"redGlass";
    [self addChild:redGlass];
    
    SKLabelNode* redPrice = [SKLabelNode labelNodeWithText:@"30 Coins"];
    redPrice.position = CGPointMake(0, -40);
    redPrice.fontColor = [UIColor yellowColor];
    redPrice.fontName = @"AppleSDGothicNeo-Bold";
    redPrice.fontSize = 15;
    if ([GameData sharedGameData].redBought) {
        redPrice.text = @"Purchased!";
    }
    [redGlass addChild:redPrice];
    
    SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
    [mustach setScale:2.2];
    mustach.position = CGPointMake(self.size.width / 3.8, greenGlass.position.y - 200);
    mustach.name = @"mustach";
    [self addChild:mustach];
    
    SKLabelNode* mustachPrice = [SKLabelNode labelNodeWithText:@"50 Coins"];
    mustachPrice.position = CGPointMake(0, -40);
    mustachPrice.fontColor = [UIColor yellowColor];
    mustachPrice.fontName = @"AppleSDGothicNeo-Bold";
    mustachPrice.fontSize = 15;
    if ([GameData sharedGameData].mustachBought) {
        mustachPrice.text = @"Purchased!";
    }
    [mustach addChild:mustachPrice];
    
    SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
    [fancyGlass setScale:2.2];
    fancyGlass.position = CGPointMake(greenGlass.position.x + greenGlass.size.width + 30, mustach.position.y);
    fancyGlass.name = @"fancyGlass";
    [self addChild:fancyGlass];
    
    SKLabelNode* fancyPrice = [SKLabelNode labelNodeWithText:@"40 Coins"];
    fancyPrice.position = CGPointMake(0, -40);
    fancyPrice.fontColor = [UIColor yellowColor];
    fancyPrice.fontName = @"AppleSDGothicNeo-Bold";
    fancyPrice.fontSize = 15;
    if ([GameData sharedGameData].fancyBought) {
        fancyPrice.text = @"Purchased!";
    }
    [fancyGlass addChild:fancyPrice];
    
    SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
    [helmet setScale:2.2];
    helmet.position = CGPointMake(purpleGlass.position.x + purpleGlass.size.width + 30, mustach.position.y);
    helmet.name = @"helmet";
    [self addChild:helmet];
    
    SKLabelNode* helmetPrice = [SKLabelNode labelNodeWithText:@"10 Coins"];
    helmetPrice.position = CGPointMake(0, -40);
    helmetPrice.fontColor = [UIColor yellowColor];
    helmetPrice.fontName = @"AppleSDGothicNeo-Bold";
    helmetPrice.fontSize = 15;
    if ([GameData sharedGameData].helmetBought) {
        helmetPrice.text = @"Purchased!";
    }
    [helmet addChild:helmetPrice];
}

// Need to change**
-(void) mergeTextures:(int) item{
    
    [bird removeAllChildren];
    
    switch (birdSelected) {
        case 1:
            [self ellaCustom: item];
            break;
        case 2:
            [self dexCustom: item];
            break;
        case 3:
            [self herbCustom: item];
            break;
        default:
            break;
    }
}


-(void) ellaCustom:(int) item{
    
    if (item == 1) {
        SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
        greenGlass.position = CGPointMake(0,-10);
        greenGlass.zPosition = 100;
        [bird addChild:greenGlass];
        birdLabel.text = @"Cool Birdie";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].greenBought = true;
    }else if(item == 2){
        SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
        purpleGlass.position = CGPointMake(0,-10);
        purpleGlass.zPosition = 100;
        [bird addChild:purpleGlass];
        birdLabel.text = @"Hipster Ella";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].purpleBought = true;

    }else if (item == 3){
        SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
        redGlass.position = CGPointMake(0,-10);
        redGlass.zPosition = 100;
        [bird addChild:redGlass];
        birdLabel.text = @"Love Queen";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].redBought = true;

    }else if (item == 4){
        SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
        mustach.position = CGPointMake(0,-20);
        mustach.zPosition = 100;
        [bird addChild:mustach];
        birdLabel.text = @"Mustach Bird?!? Whaaa";
        birdLabel.fontSize = 55;
        [GameData sharedGameData].mustachBought = true;
        [self updateAchievements]; // Achievement for buying a mustach


    }else if (item == 5){
        SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
        fancyGlass.position = CGPointMake(19,-10);
        fancyGlass.zPosition = 100;
        [bird addChild:fancyGlass];
        birdLabel.text = @"Call me Fancy";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].fancyBought = true;

    }else if (item == 6){
        SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
        helmet.position = CGPointMake(0,19);
        helmet.zPosition = 100;
        [bird addChild:helmet];
        birdLabel.text = @"Head gear required!";
        birdLabel.fontSize = 70;
        [GameData sharedGameData].helmetBought = true;

    }
    
    [[GameData sharedGameData] save];
    
}

-(void) dexCustom:(int) item{
    if (item == 1) {
        SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
        [greenGlass setScale:7];
        greenGlass.position = CGPointMake(-18,-29);
        greenGlass.zPosition = 100;
        [bird addChild:greenGlass];
        birdLabel.text = @"Cool Birdie";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].greenBought = true;

    }else if(item == 2){
        SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
        [purpleGlass setScale:7];
        purpleGlass.position = CGPointMake(-18,-29);
        purpleGlass.zPosition = 100;
        [bird addChild:purpleGlass];
        birdLabel.text = @"Hipster Dex";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].purpleBought = true;

    }else if (item == 3){
        SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
        [redGlass setScale:7.5];
        redGlass.position = CGPointMake(-18,-29);
        redGlass.zPosition = 100;
        [bird addChild:redGlass];
        birdLabel.text = @"Love King";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].redBought = true;

    }else if (item == 4){
        SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
        [mustach setScale:7];
        mustach.position = CGPointMake(-25,-110);
        mustach.zPosition = 100;
        [bird addChild:mustach];
        birdLabel.text = @"Mustach Bird?!? Whaaa";
        birdLabel.fontSize = 55;
        [GameData sharedGameData].mustachBought = true;
        [self updateAchievements]; // Achievement for buying a mustach


    }else if (item == 5){
        SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
        [fancyGlass setScale:7];
        fancyGlass.position = CGPointMake(160,-35);
        fancyGlass.zPosition = 100;
        [bird addChild:fancyGlass];
        birdLabel.text = @"Call me Fancy";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].fancyBought = true;

    }else if (item == 6){
        SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
        [helmet setScale:7];
        helmet.position = CGPointMake(-20,180);
        helmet.zPosition = 100;
        [bird addChild:helmet];
        birdLabel.text = @"Head gear required!";
        birdLabel.fontSize = 70;
        [GameData sharedGameData].helmetBought = true;

    }
    
    [[GameData sharedGameData] save];
}

-(void) herbCustom:(int) item{
    if (item == 1) {
        SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
        [greenGlass setScale:7];
        greenGlass.position = CGPointMake(-5,-18);
        greenGlass.zPosition = 100;
        [bird addChild:greenGlass];
        birdLabel.text = @"Cool Birdie";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].greenBought = true;

    }else if(item == 2){
        SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
        [purpleGlass setScale:7];
        purpleGlass.position = CGPointMake(-5,-22);
        purpleGlass.zPosition = 100;
        [bird addChild:purpleGlass];
        birdLabel.text = @"Hipster Dex";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].purpleBought = true;

    }else if (item == 3){
        SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
        [redGlass setScale:7.5];
        redGlass.position = CGPointMake(-5,-22);
        redGlass.zPosition = 100;
        [bird addChild:redGlass];
        birdLabel.text = @"Love King";
        birdLabel.fontSize = 110;
        [GameData sharedGameData].redBought = true;

    }else if (item == 4){
        SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
        [mustach setScale:7];
        mustach.position = CGPointMake(-10,-110);
        mustach.zPosition = 100;
        [bird addChild:mustach];
        birdLabel.text = @"Mustach Bird?!? Whaaa";
        birdLabel.fontSize = 55;
        [GameData sharedGameData].mustachBought = true;
        [self updateAchievements]; // Achievement for buying a mustach

    }else if (item == 5){
        SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
        [fancyGlass setScale:7];
        fancyGlass.position = CGPointMake(120,-5);
        fancyGlass.zPosition = 100;
        [bird addChild:fancyGlass];
        birdLabel.text = @"Call me Fancy";
        birdLabel.fontSize = 90;
        [GameData sharedGameData].fancyBought = true;

    }else if (item == 6){
        SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
        [helmet setScale:7];
        helmet.position = CGPointMake(0,180);
        helmet.zPosition = 100;
        [bird addChild:helmet];
        birdLabel.text = @"Head gear required!";
        birdLabel.fontSize = 70;
        [GameData sharedGameData].helmetBought = true;

    }
    
    [[GameData sharedGameData] save];

}

-(void)updateAchievements{
    
    NSString *achievementIdentifier = @"Mustache_Bought";
    float progressPercentage = 100.0;
    GKAchievement *completionAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
    completionAchievement.percentComplete = progressPercentage;
    if (completionAchievement.percentComplete == 100.0) {
        completionAchievement.showsCompletionBanner = true;
    }
    
    NSArray *achievements = @[completionAchievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
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
