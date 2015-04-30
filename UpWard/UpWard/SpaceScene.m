//
//  SpaceScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/30/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "SpaceScene.h"
#import "SpaceLevelSprite.h"

@implementation SpaceScene

-(SKNode*) createSpaceScene{
    
    SKNode* spaceContainer = [SKNode node];
    
    SKTexture* starsTextures = [SKTexture textureWithImageNamed:@"starsBG"];
    starsBG = [SKSpriteNode spriteNodeWithTexture: starsTextures];
    [starsBG setScale:.9];
    starsBG.position = CGPointMake(CGRectGetMidX(self.frame), 10);
    starsBG.zPosition = -50;
    [spaceContainer addChild:starsBG];
    //[_moving addChild:starsBG];
    
    SKAction* starsMove = [SKAction moveByX:0 y:-starsBG.size.height + 200 duration:2 * starsBG.size.height];
    keepStars = [SKAction repeatActionForever:starsMove];
    
    saturn = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_SATURN];
    [saturn setScale:.8];
    saturn.position = CGPointMake(600, 500);
    saturn.zPosition = -30;
    [spaceContainer addChild:saturn];
    //[_moving addChild:saturn];
    
    SKAction* saturnMove = [SKAction moveByX:80 y:-saturn.size.height * 2 duration:.55 * saturn.size.height * 2];
    keepSaturn = [SKAction repeatActionForever:saturnMove];
    
    jupiter = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_JUPITER];
    [jupiter setScale:.8];
    jupiter.position = CGPointMake(200, 1000);
    jupiter.zPosition = -29;
    [spaceContainer addChild:jupiter];
    //[_moving addChild:jupiter];
    
    SKAction* jupiterMove = [SKAction moveByX:-180 y:-jupiter.size.height * 2 duration:.55 * jupiter.size.height * 2];
    keepJupiter = [SKAction repeatActionForever:jupiterMove];
    
    venus = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_VENUS];
    [venus setScale:.8];
    venus.position = CGPointMake(300, 1300);
    venus.zPosition = -29;
    [spaceContainer addChild:venus];
    //[_moving addChild:venus];
    
    SKAction* venusMove = [SKAction moveByX:0 y:-venus.size.height * 2 duration:.55 * venus.size.height * 2];
    keepVenus = [SKAction repeatActionForever:venusMove];
    
    neptune = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_NEPTUNE];
    [neptune setScale:.8];
    neptune.position = CGPointMake(100, 1600);
    neptune.zPosition = -29;
    [spaceContainer addChild:neptune];
    //[_moving addChild:neptune];
    
    SKAction* neptuneMove = [SKAction moveByX:-50 y:-neptune.size.height * 2 duration:.55 * neptune.size.height * 2];
    keepNeptune = [SKAction repeatActionForever:neptuneMove];
    

    return spaceContainer;
}

-(void) moveSpace{
    
    [starsBG runAction:keepStars withKey:@"BGAnim"];
    [saturn runAction:keepSaturn withKey:@"BGAnim"];
    [venus runAction:keepVenus withKey:@"BGAnim"];
    [jupiter runAction:keepJupiter withKey:@"BGAnim"];
    [neptune runAction:keepNeptune withKey:@"BGAnim"];
    
}

-(void) resetMovement{ // will need to look further, slow on the first game but then speeds up!
    
    [starsBG removeActionForKey:@"BGAnim"];
    [saturn removeActionForKey:@"BGAnim"];
    [venus removeActionForKey: @"BGAnim"];
    [jupiter removeActionForKey: @"BGAnim"];
    [neptune removeActionForKey: @"BGAnim"];
    
}

@end
