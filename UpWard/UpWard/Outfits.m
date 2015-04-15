//
//  Outfits.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "Outfits.h"
//
//  BirdsSelection.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//
//

#import "GameScene.h"
#import "BirdsSelection.h"
#import "Sprites.h"
#import "BirdsSprite.h"
#import "GameData.h"
#import "LevelSprites.h"

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
        
    }else if([node.name isEqualToString:@"ella"]){
        [GameData sharedGameData].birdSelected = 1;
    }else if([node.name isEqualToString:@"dex"]){
        [GameData sharedGameData].birdSelected = 2;
    }else if([node.name isEqualToString:@"herb"]){
        [GameData sharedGameData].birdSelected = 3;
    }
}

-(void) createIntro{
    
    SKColor* background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    
    self.backgroundColor = background;
    
    int birdSelected = [GameData sharedGameData].birdSelected;
    
    if (birdSelected == 1) {
        birdTexture = SPRITES_TEX_ELLA;
        birdName = @"Ella";
        scale = 4;
    }else if(birdSelected == 2){
        birdTexture = BIRDSSPRITE_TEX_DEX;
        birdName = @"Dex";
        scale = .7;
    }else if (birdSelected == 3){
        birdTexture = BIRDSSPRITE_TEX_HERB;
        birdName = @"Herb";
        scale = .7;
    }
    
    SKSpriteNode* bird = [SKSpriteNode spriteNodeWithTexture:birdTexture];
    [bird setScale:scale];
    bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 250);
    [self addChild:bird];
    
    birdLabel = [SKLabelNode labelNodeWithText:birdName];
    birdLabel.position = CGPointMake(CGRectGetMidX(self.frame), bird.position.y -250);
    birdLabel.fontSize = 110;
    [self addChild:birdLabel];

    
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
    
    [self createStore];
    
    [self initActions];
    
}

-(void) createStore{
    
    SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
    [greenGlass setScale:2.2];
    greenGlass.position = CGPointMake(self.size.width / 3.8, 400);
    greenGlass.name = @"greenGlass";
    [self addChild:greenGlass];
    
    SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
    [purpleGlass setScale:2.2];
    purpleGlass.position = CGPointMake(greenGlass.position.x + greenGlass.size.width + 30, 400);
    purpleGlass.name = @"blackGlass";
    [self addChild:purpleGlass];
    
    SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
    [redGlass setScale:2.2];
    redGlass.position = CGPointMake(purpleGlass.position.x + purpleGlass.size.width + 30, 400);
    redGlass.name = @"redGlass";
    [self addChild:redGlass];
    
    SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
    [mustach setScale:2.2];
    mustach.position = CGPointMake(self.size.width / 3.8, greenGlass.position.y - 100);
    mustach.name = @"mustach";
    [self addChild:mustach];
    
    SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
    [fancyGlass setScale:2.2];
    fancyGlass.position = CGPointMake(greenGlass.position.x + greenGlass.size.width + 30, greenGlass.position.y - 100);
    fancyGlass.name = @"fancyGlass";
    [self addChild:fancyGlass];
    
    SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
    [helmet setScale:2.2];
    helmet.position = CGPointMake(purpleGlass.position.x + purpleGlass.size.width + 30, greenGlass.position.y - 100);
    helmet.name = @"helmet";
    [self addChild:helmet];
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
