//
//  GameData.h
//  UpWard
//
//  Created by Nazir Shuqair on 3/25/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject <NSCoding>

@property (assign, nonatomic) long score;
@property (assign, nonatomic) long highScore;
@property (assign, nonatomic) long coinsCollected;
@property (assign, nonatomic) long chicksCollected;
@property (assign, nonatomic) int birdSelected;

+(instancetype)sharedGameData;
-(void)reset;
-(void)save;


@end
