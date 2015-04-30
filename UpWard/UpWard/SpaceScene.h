//
//  SpaceScene.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/30/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SpaceScene : SKNode{
    
    //Space level--------------------------------
    
    SKSpriteNode* starsBG;
    SKSpriteNode* neptune;
    SKSpriteNode* jupiter;
    SKSpriteNode* saturn;
    SKSpriteNode* venus;
    
    SKAction* keepStars;
    SKAction* keepJupiter;
    SKAction* keepNeptune;
    SKAction* keepVenus;
    SKAction* keepSaturn;
    
    //-------------------------------------------
}

-(SKNode*) createSpaceScene;
-(void) moveSpace;
-(void) resetMovement;
-(SKTexture*) shelveTexture;

@end
