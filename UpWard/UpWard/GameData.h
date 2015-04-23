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
@property (assign, nonatomic) int accessorySelected;
@property (assign, nonatomic) int levelSelected;
@property (assign, nonatomic) Boolean spaceLevelBought;


@property (assign, nonatomic) bool dexBought;
@property (assign, nonatomic) bool herbBought;


@property (assign, nonatomic) bool greenBought;
@property (assign, nonatomic) bool purpleBought;
@property (assign, nonatomic) bool redBought;
@property (assign, nonatomic) bool fancyBought;
@property (assign, nonatomic) bool mustachBought;
@property (assign, nonatomic) Boolean helmetBought;

//Testing leaderboard
@property (nonatomic, strong) NSMutableArray* forrestLeaderboard;


+(instancetype)sharedGameData;
-(void)reset;
-(void)save;


@end
