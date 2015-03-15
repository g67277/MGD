//
//  PhysicsContainerNode.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "PhysicsContainerNode.h"

@implementation PhysicsContainerNode

static const uint32_t sidesCategory = 1 << 1;
static const uint32_t floorCategory = 1 << 2;
static const uint32_t roofCategory = 1 << 5;

-(SKNode *) leftSide{

    SKNode* leftSideNode = [SKNode node];
    leftSideNode.position = CGPointMake(1, 1);
    leftSideNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width / 1.7, self.frame.size.height * 2)];
    leftSideNode.physicsBody.dynamic = NO;
    leftSideNode.physicsBody.categoryBitMask = sidesCategory;
    
    return leftSideNode;
}

-(SKNode*) rightSide{
    SKNode* rightSideNode = [SKNode node];
    rightSideNode.position = CGPointMake(self.frame.size.width, 1);
    rightSideNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width / 1.72, self.frame.size.height * 2)];
    rightSideNode.physicsBody.dynamic = NO;
    rightSideNode.physicsBody.categoryBitMask = sidesCategory;
    
    return rightSideNode;
}

-(SKNode *) floor{
    SKNode* _dummyFloor = [SKNode node];
    _dummyFloor.position = CGPointMake(1, 1);
    _dummyFloor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    _dummyFloor.physicsBody.dynamic = NO;
    _dummyFloor.physicsBody.categoryBitMask = floorCategory;
    
    return _dummyFloor;
}

-(SKNode *) roof{
    
    SKNode* _dummyRoof = [SKNode node];
    _dummyRoof.position = CGPointMake(1, self.frame.size.height);
    _dummyRoof.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    _dummyRoof.physicsBody.dynamic = NO;
    _dummyRoof.physicsBody.categoryBitMask = roofCategory;
    
    return _dummyRoof;
}


@end
