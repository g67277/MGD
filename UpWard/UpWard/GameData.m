//
//  GameData.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/25/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "GameData.h"

@implementation GameData

static NSString* const GameDataHighScoreKey = @"highScore";
static NSString* const GameDataCoinsKey = @"coins";
static NSString* const GameDataChicksKey = @"chicks";
static NSString* const GameDataBirdKey = @"birds";
static NSString* const GameDataAccessoryKey = @"accessory";

static NSString* const GameDataDexKey = @"dex";
static NSString* const GameDataHerbKey = @"herb";

static NSString* const GameDataGreenKey = @"green";
static NSString* const GameDataPurpleKey = @"purple";
static NSString* const GameDataRedKey = @"red";
static NSString* const GameDataFancyKey = @"fancy";
static NSString* const GameDataMustachKey = @"mustach";
static NSString* const GameDataHelmetKey = @"helmet";


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.highScore forKey: GameDataHighScoreKey];
    [encoder encodeDouble:self.coinsCollected forKey:GameDataCoinsKey];
    [encoder encodeDouble:self.chicksCollected forKey:GameDataChicksKey];
    [encoder encodeInt:self.birdSelected forKey:GameDataBirdKey];
    [encoder encodeInt:self.accessorySelected forKey:GameDataAccessoryKey];
    
    [encoder encodeBool:self.dexBought forKey:GameDataDexKey];
    [encoder encodeBool:self.herbBought forKey:GameDataHerbKey];

    [encoder encodeBool:self.greenBought forKey:GameDataGreenKey];
    [encoder encodeBool:self.purpleBought forKey:GameDataPurpleKey];
    [encoder encodeBool:self.redBought forKey:GameDataRedKey];
    [encoder encodeBool:self.fancyBought forKey:GameDataFancyKey];
    [encoder encodeBool:self.mustachBought forKey:GameDataMustachKey];
    [encoder encodeBool:self.helmetBought forKey:GameDataHelmetKey];


}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _highScore = [decoder decodeDoubleForKey: GameDataHighScoreKey];
        _coinsCollected = [decoder decodeDoubleForKey:GameDataCoinsKey];
        _chicksCollected = [decoder decodeDoubleForKey:GameDataChicksKey];
        _birdSelected = [decoder decodeIntForKey:GameDataBirdKey];
        _accessorySelected = [decoder decodeIntForKey:GameDataAccessoryKey];
        
        _dexBought = [decoder decodeBoolForKey:GameDataDexKey];
        _herbBought = [decoder decodeBoolForKey:GameDataHerbKey];
        
        _greenBought = [decoder decodeBoolForKey:GameDataGreenKey];
        _purpleBought = [decoder decodeBoolForKey:GameDataPurpleKey];
        _redBought = [decoder decodeBoolForKey:GameDataRedKey];
        _fancyBought = [decoder decodeBoolForKey:GameDataFancyKey];
        _mustachBought = [decoder decodeBoolForKey:GameDataMustachKey];
        _helmetBought = [decoder decodeBoolForKey:GameDataHelmetKey];


    }
    return self;
}

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[GameData alloc] init];
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
}

-(void)reset
{
    self.score = 0;
}

@end
