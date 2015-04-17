//
//  LevelSelection.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/16/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>



@interface LevelSelection : SKScene <UIAlertViewDelegate>{
    SKLabelNode* spaceLabel;
    int levelSelected;
    SKLabelNode* coinsCollectedLabel;
}

@end
