//
//  ScoreData.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/19/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "ScoreData.h"

@implementation ScoreData
@synthesize username = _username, score = _score, date = _date;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.score = [aDecoder decodeIntForKey:@"score"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeInt:_score forKey:@"score"];
    
}




@end
