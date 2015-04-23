//
//  BirdsSelection.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BirdsSelection : SKScene <UIAlertViewDelegate>{
    int birdSelected;
    
    SKLabelNode* dexLabel;
    SKLabelNode* herbLabel;
    SKLabelNode* chicksCountLabel;
}

@end
