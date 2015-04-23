//
//  ScoreData.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/19/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookObj : NSObject <NSCoding>

@end

@interface ScoreData : NSObject

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* date;
@property (nonatomic, readwrite) int score;


@end
