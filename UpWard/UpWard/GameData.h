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

+(instancetype)sharedGameData;
-(void)reset;
-(void)save;


@end
