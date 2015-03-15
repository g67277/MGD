//
//  PhysicsContainerNode.h
//  UpWard
//
//  Created by Nazir Shuqair on 3/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PhysicsContainerNode : SKNode

-(SKNode *) leftSide;
-(SKNode *) rightSide;
-(SKNode *) floor;
-(SKNode *) roof;

@end
