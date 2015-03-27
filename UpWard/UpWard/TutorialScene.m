//
//  TutorialScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/26/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "TutorialScene.h"
#import "MainMenu.h"
#import "GameScene.h"

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

@implementation TutorialScene

-(void)didMoveToView:(SKView *)view {
    
    tapCount = 1;
    
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
        
    }else{
        
        tapCount++;
        if (tapCount < 9) {
            NSString* imageName = [NSString stringWithFormat:@"tutorial%i", tapCount];
            background.texture = [SKTexture textureWithImageNamed:imageName];
        }else{
            
            GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            // Present the scene.
            [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
            //[skView presentScene:scene];
        }
        
        
    }
}

-(void) createIntro{
    
    SKSpriteNode* backBtn = [SKSpriteNode spriteNodeWithImageNamed:@"back"];
    [backBtn setScale:.5];
    backBtn.position = CGPointMake(self.size.width / 4 - 40, self.size.height - backBtn.size.height / 2 - 20);
    backBtn.zPosition = 1;
    backBtn.name = @"backBtn";
    [self addChild:backBtn];
    
    background = [SKSpriteNode spriteNodeWithImageNamed:@"tutorial1"];
    [background setScale:1.2];
    background.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    background.zPosition = -20;
    [self addChild:background];
    
    [self continueLabel];
    [self initActions];
    [continueTap runAction:scallingForever];
    
}

-(void) continueLabel{
    
    continueTap = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    continueTap.fontColor = [UIColor grayColor];
    continueTap.fontSize = 40;
    continueTap.position = CGPointMake(self.size.width / 2, self.size.height / 3.4);
    continueTap.zPosition = 101;
    continueTap.text = @"Tap to Continue";
    [self addChild:continueTap];

}

-(void) initActions{
    
    SKAction* repeatScalling = [SKAction sequence:@[[SKAction scaleTo:1.3 duration:0.6], [SKAction scaleTo:1.0 duration:0.6]]];

    scallingForever = [SKAction repeatActionForever:repeatScalling];

}


@end
