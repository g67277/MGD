//
//  ForrestScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/30/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "ForrestScene.h"
#import "LevelSprites.h"

@implementation ForrestScene

-(SKNode*) createScene{
    
    SKNode* forrestNode = [SKNode node];
    
    //Parallax background
    //Grass background
    grass = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:98/255.0f green:204/255.0f blue:103/255.0f alpha:1.0f] size:CGSizeMake(1000, 900)];
    grass.position = CGPointMake(grass.size.width /2 , grass.size.height / 2);
    grass.zPosition = -100;
    [forrestNode addChild:grass];
    
    SKAction* grassMove = [SKAction moveByX:0 y: -grass.size.height * 2 duration:1.0 * grass.size.height * 2];
    keepGM = [SKAction repeatActionForever:grassMove];

    //Front tree
    frontTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_FIRSTTREE];
    frontTree.position = CGPointMake(90, frontTree.size.height /2 );
    frontTree.zPosition = -14;
    [forrestNode addChild:frontTree];
    
    SKAction* frontTreeMove = [SKAction moveByX:-frontTree.size.width y: -frontTree.size.height * 2 duration:.3 * frontTree.size.height * 2];
    keepFTM = [SKAction repeatActionForever:frontTreeMove];
    
    //Left Tree
    leftTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_LEFTTREE];
    leftTree.position = CGPointMake(650, leftTree.size.height / 2 - 5);
    leftTree.zPosition = -20;
    [forrestNode addChild:leftTree];
    
    SKAction* leftTreeMove = [SKAction moveByX:leftTree.size.width / 2 y: -leftTree.size.height * 2 duration:.2 * leftTree.size.height * 2];
    keepLTM = [SKAction repeatActionForever:leftTreeMove];
    
    //Right Tree
    rightTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_RIGHTTREE];
    rightTree.position = CGPointMake(120, rightTree.size.height / 1.7);
    rightTree.zPosition = -20;
    [forrestNode addChild:rightTree];
    
    SKAction* rightTreeMove = [SKAction moveByX:-rightTree.size.width / 2 y: -rightTree.size.height * 2 duration:.2 * rightTree.size.height * 2];
    keepRTM = [SKAction repeatActionForever:rightTreeMove];
    
    //Right Mid Tree
    rightMidTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_RIGHTMIDTREE];
    rightMidTree.position = CGPointMake(250, rightMidTree.size.height);
    rightMidTree.zPosition = -19;
    [forrestNode addChild:rightMidTree];
    
    SKAction* rightMidTreeMove = [SKAction moveByX:-rightMidTree.size.width / 3 y: -rightMidTree.size.height * 2 duration:.4 * rightMidTree.size.height * 2];
    keepRMTM = [SKAction repeatActionForever:rightMidTreeMove];

    //Left Mid Tree
    leftMidTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_LEFTMIDTREE];
    leftMidTree.position = CGPointMake(480, leftMidTree.size.height);
    leftMidTree.zPosition = -22;
    [forrestNode addChild:leftMidTree];
    
    SKAction* leftMidTreeMove = [SKAction moveByX:leftMidTree.size.width / 3 y: -leftMidTree.size.height * 2 duration:.4 * leftMidTree.size.height * 2];
    keepLMTM = [SKAction repeatActionForever:leftMidTreeMove];
    
    //Mid Tree
    midTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_MIDTREE];
    midTree.position = CGPointMake(384, midTree.size.height * 1.13);
    midTree.zPosition = -18;
    [forrestNode addChild:midTree];
    
    SKAction* midTreeMove = [SKAction moveByX:0 y: -midTree.size.height * 2 duration:.4 * midTree.size.height * 2];
    keepMTM = [SKAction repeatActionForever:midTreeMove];
    
    //Background trees
    bGTrees = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_BACKGROUNDTREES];
    [bGTrees setScale:1.1];
    bGTrees.position = CGPointMake(430, bGTrees.size.height * 2);
    bGTrees.zPosition = -25;
    [forrestNode addChild:bGTrees];
    
    //Lake
    lake = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_LAKE];
    lake.position = CGPointMake(384, lake.size.height * 4.8);
    lake.zPosition = -40;
    [forrestNode addChild:lake];
    
    SKAction* bGTreesNLake = [SKAction moveByX:0 y: -bGTrees.size.height * 2 duration:.4 * bGTrees.size.height * 2];
    keepBGTL = [SKAction repeatActionForever:bGTreesNLake];

    //small Mountains
    smallMount1 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_SMALLMOUNTAIN];
    smallMount1.position = CGPointMake(384, smallMount1.size.height * 3.8);
    smallMount1.zPosition = -30;
    [forrestNode addChild:smallMount1];
    
    SKAction* smallMount1Move = [SKAction moveByX:0 y: -smallMount1.size.height * 2 duration:.4 * smallMount1.size.height * 2];
    keepSM1 = [SKAction repeatActionForever:smallMount1Move];
    
    smallMount2 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_SMALLMOUNTAIN];
    smallMount2.position = CGPointMake(smallMount2.size.width / 4, smallMount1.size.height * 3.8);
    smallMount2.zPosition = -31;
    [forrestNode addChild:smallMount2];
    
    SKAction* smallMount2Move = [SKAction moveByX:0 y: -smallMount1.size.height * 2 duration:.45 * smallMount1.size.height * 2];
    keepSM2 = [SKAction repeatActionForever:smallMount2Move];
    
    smallMount3 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_SMALLMOUNTAIN];
    smallMount3.position = CGPointMake(smallMount3.size.width, smallMount1.size.height * 3.8);
    smallMount3.zPosition = -31;
    [forrestNode addChild:smallMount3];
    
    SKAction* smallMount3Move = [SKAction moveByX:0 y: -smallMount1.size.height * 2 duration:.43 * smallMount1.size.height * 2];
    keepSM3 = [SKAction repeatActionForever:smallMount3Move];
    
    //Large mountains
    largeMount1 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_BIGMOUNTAIN];
    largeMount1.position = CGPointMake(549, smallMount1.size.height * 5);
    largeMount1.zPosition = -34;
    [forrestNode addChild:largeMount1];
    
    SKAction* largeMount1Move = [SKAction moveByX:0 y: -largeMount1.size.height * 2 duration:.5 * largeMount1.size.height * 2];
    keepLM1 = [SKAction repeatActionForever:largeMount1Move];
    
    largeMount2 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_BIGMOUNTAIN];
    [largeMount2 setScale:.8];
    largeMount2.position = CGPointMake(256, smallMount1.size.height * 5);
    largeMount2.zPosition = -35;
    [forrestNode addChild:largeMount2];
    
    SKAction* largeMount2Move = [SKAction moveByX:0 y: -largeMount1.size.height * 2 duration:.55 * largeMount1.size.height * 2];
    keepLM2 = [SKAction repeatActionForever:largeMount2Move];
    
    return forrestNode;
}

-(SKTexture*) shelveTexture{
    
    SKTexture* shelves = [SKTexture textureWithImageNamed:@"mountShelve"];
    return shelves;
}

-(void) moveScene{
    
    [frontTree runAction:keepFTM withKey:@"BGAnim"];
    [leftTree runAction:keepLTM withKey:@"BGAnim"];
    [rightTree runAction:keepRTM withKey:@"BGAnim"];
    [rightMidTree runAction:keepRMTM withKey:@"BGAnim"];
    [leftMidTree runAction:keepLMTM withKey:@"BGAnim"];
    [midTree runAction:keepMTM withKey:@"BGAnim"];
    [bGTrees runAction:keepBGTL withKey:@"BGAnim"];
    [lake runAction:keepBGTL withKey:@"BGAnim"];
    [smallMount1 runAction:keepSM1 withKey:@"BGAnim"];
    [smallMount2 runAction:keepSM2 withKey:@"BGAnim"];
    [smallMount3 runAction:keepSM3 withKey:@"BGAnim"];
    [largeMount1 runAction:keepLM1 withKey:@"BGAnim"];
    [largeMount2 runAction:keepLM2 withKey:@"BGAnim"];
    [grass runAction:keepGM withKey:@"BGAnim"];
}

-(void) resetMovement{
    
    
    [grass removeActionForKey:@"BGAnim"];
    [frontTree removeActionForKey:@"BGAnim"];
    [leftTree removeActionForKey:@"BGAnim"];
    [rightTree removeActionForKey:@"BGAnim"];
    [rightMidTree removeActionForKey:@"BGAnim"];
    [leftMidTree removeActionForKey:@"BGAnim"];
    [midTree removeActionForKey:@"BGAnim"];
    [bGTrees removeActionForKey:@"BGAnim"];
    [lake removeActionForKey:@"BGAnim"];
    [smallMount1 removeActionForKey:@"BGAnim"];
    [smallMount2 removeActionForKey:@"BGAnim"];
    [smallMount3 removeActionForKey:@"BGAnim"];
    [largeMount1 removeActionForKey:@"BGAnim"];
    [largeMount2 removeActionForKey:@"BGAnim"];
    
}

@end
