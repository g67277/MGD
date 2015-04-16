//
//  Outfits.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/15/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Outfits : SKScene <UIAlertViewDelegate>{
    
    SKLabelNode* birdLabel;
    SKTexture* birdTexture;
    NSString* birdName;
    float scale;
    int birdSelected;
    int accessorySelected;
    SKSpriteNode* bird;
    SKLabelNode* currentCoin;
}

@end
