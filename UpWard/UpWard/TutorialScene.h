//
//  TutorialScene.h
//  UpWard
//
//  Created by Nazir Shuqair on 3/26/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TutorialScene : SKScene{
    
    int tapCount;
    
    SKSpriteNode* background;
    SKLabelNode* continueTap;
    SKAction* scallingForever;
}

@end
