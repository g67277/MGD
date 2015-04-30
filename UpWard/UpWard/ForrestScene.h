//
//  ForrestScene.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/30/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ForrestScene : SKNode{
    
    //Scene SkSpriteNodes
    SKSpriteNode* grass;
    SKSpriteNode* frontTree;
    SKSpriteNode* rightTree;
    SKSpriteNode* leftTree;
    SKSpriteNode* rightMidTree;
    SKSpriteNode* leftMidTree;
    SKSpriteNode* midTree;
    SKSpriteNode* bGTrees;
    SKSpriteNode* lake;
    SKSpriteNode* smallMount1;
    SKSpriteNode* smallMount2;
    SKSpriteNode* smallMount3;
    SKSpriteNode* largeMount1;
    SKSpriteNode* largeMount2;
    
    //Scene Animation
    SKAction* keepGM;
    SKAction* keepFTM;
    SKAction* keepLTM;
    SKAction* keepRTM;
    SKAction* keepRMTM;
    SKAction* keepLMTM;
    SKAction* keepMTM;
    SKAction* keepBGTL;
    SKAction* keepSM1;
    SKAction* keepSM2;
    SKAction* keepSM3;
    SKAction* keepLM1;
    SKAction* keepLM2;
    
}

-(SKNode*) createScene;
-(void) moveScene;
-(void) resetMovement;
-(SKTexture*) shelveTexture;

@end
