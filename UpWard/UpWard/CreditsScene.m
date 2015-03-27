//
//  CreditsScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/26/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "CreditsScene.h"
#import "MainMenu.h"
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

@implementation CreditsScene

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
    if ([node.name isEqualToString:@"backBtn"]) {
        
        MainMenu *scene = [MainMenu unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
        //[skView presentScene:scene];
        
    }
}

-(void) createIntro{
    
    SKSpriteNode* backBtn = [SKSpriteNode spriteNodeWithImageNamed:@"back"];
    [backBtn setScale:.5];
    backBtn.position = CGPointMake(self.size.width / 4 - 40, self.size.height - backBtn.size.height / 2 - 20);
    backBtn.zPosition = 1;
    backBtn.name = @"backBtn";
    [self addChild:backBtn];
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"creditsScene"];
    [background setScale:[self deviceSize]];
    background.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    background.zPosition = -20;
    [self addChild:background];
    
}

#pragma Device Type/Size methods

- (float)deviceSize{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 1.2;
        
    } else {
        return 1.6;
    }
    
    return 0;
}


@end
