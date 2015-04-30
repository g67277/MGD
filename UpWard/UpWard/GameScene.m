//
//  GameScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/2/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "GameScene.h"
#import "Sprites.h"
#import "BirdsSprite.h"
#import "LevelSprites.h"
#import "GameData.h"
#import "MainMenu.h"
#import "GameViewController.h"
@import GameKit;

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameScene

static const uint32_t birdCategory = 1 << 0;
static const uint32_t sidesCategory = 1 << 1;
static const uint32_t floorCategory = 1 << 2;
static const uint32_t shelvesCategory = 1 << 3;
static const uint32_t shelvesFloorCategory = 1 << 4;
static const uint32_t roofCategory = 1 << 5;
static const uint32_t scoreCategory = 1 << 6;
static const uint32_t catCategory = 1 << 7;
static const uint32_t chickCategory = 1 << 8;

NSString *const BodyRightWall = @"bodyRightWall";
NSString *const BodyLeftWall = @"bodyLeftWall";
NSString *const SolidShelvePosition = @"solidShelvePosition";
NSString *const HorizontalShelveGap = @"HorizontalShelveGap";

-(void)didMoveToView:(SKView *)view {
    
    username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    scoresArray = [[NSMutableArray alloc] init];
    incomingScoresArray = [[NSMutableArray alloc] init];
    spaceLevel = [[SpaceScene alloc] init];
    forrestLevel = [[ForrestScene alloc] init];
    goingLeft = false;
    lost = false;
    flapCount = 0;
    worldSpeed = 3.5;
    initialDelay = 1.7;
    shelveDelay = 1.5;
    kHorizontalShelveGap = [self deviceSize:HorizontalShelveGap];
    //Initializing refrence array
    shelvesReference = [[NSMutableArray alloc] init];
    coinsReference = [[NSMutableArray alloc]init];
    chicksReference = [[NSMutableArray alloc] init];
    //Change the world gravity
    self.physicsWorld.gravity = CGVectorMake( 0.0, -6.0 );
    self.physicsWorld.contactDelegate = self;
    _sceneSize = (SKView *)self.view;
    shelveCount = 0;
    shelveCountChicks = 0;
    
    //Code needs refactoring***
    levelSelected = [GameData sharedGameData].levelSelected;
    
    _moving = [SKNode node];
    [self addChild:_moving];
    
    //Speed of the game
    _moving.speed = worldSpeed;
    _shelves = [SKNode node];
    [_moving addChild:_shelves];
    [self playMusic:@"BGMusic" withLoop:YES];
    
    //Adding the container
    [self physicsContainer];
    [self levelSelector];
    [self createHeader];
    [self createIntro];
    [self playLevel];
    
    //Background for the level
    self.backgroundColor = _background;
}

-(void) levelSelector{
    
    if (levelSelected < 2) {
        [self createForrestScene];
    }else{
        [self createSpaceScene];
    }
}


-(void)updateAchievements:(NSString*) type{
    
    float currentScore = [GameData sharedGameData].score;
    
    NSString *achievementIdentifier;
    float progressPercentage = 0.0;
    GKAchievement *scoreAchievement = nil;
    
    if ([type isEqualToString:@"scoreIncrease"]) {
        if (currentScore <= 15) {
            progressPercentage = currentScore * 100 / 15;
            achievementIdentifier = @"15_Shelves";
        }
        else if (currentScore <= 30){
            progressPercentage = currentScore * 100 / 30;
            achievementIdentifier = @"30_Shelves";
        }
        else if (currentScore <= 50){
            progressPercentage = currentScore * 100 / 50;
            achievementIdentifier = @"50_Shelves";
        }else if (currentScore <= 100){
            progressPercentage = currentScore * 100 / 100;
            achievementIdentifier = @"100_Shelves";
        }
    }else if ([type isEqualToString:@"gameEnded"]){
        
        NSMutableArray* scoreTesting = [self decodeData:[[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]];
        NSArray* reversed = [[scoreTesting reverseObjectEnumerator] allObjects];
        if (reversed.count > 3) {
            ScoreData* latest = reversed[0];
            ScoreData* second = reversed[1];
            bool allGood = false;
            if (latest.score > second.score) {
                for (int i = 2 ; i >= 0; i--) {
                    latest = reversed[i];
                    second = reversed[i + 1];
                    if (latest.score > second.score) {
                        progressPercentage += i * 100.0 / 3;
                        allGood = true;
                        NSLog(@"good");
                    }else{
                        NSLog(@"Not good");
                        allGood = false;
                        return;
                    }
                }
                achievementIdentifier = @"Score_Increased";
            }
            
            latest = reversed[0];
            if ((latest.score < 15 && reversed.count > 10) && !allGood) {
                bool allBad = false;
                for (int i = 9; i >= 0; i--) {
                    latest = reversed[i];
                    if (latest.score < 15) {
                        allBad = true;
                    }else{
                        allBad = false;
                        return;
                    }
                }
                if (allBad) {
                    progressPercentage = 100.0;
                    achievementIdentifier = @"10_Loses";
                }
            }
        }
        
        
    }
    
    scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
    scoreAchievement.percentComplete = progressPercentage;
    if (scoreAchievement.percentComplete == 100.0) {
        scoreAchievement.showsCompletionBanner = true;
    }
    
    NSArray *achievements = @[scoreAchievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (NSMutableArray*) decodeData: (NSMutableArray*) encodedArray{
    
    NSMutableArray* decodedObjects = [[NSMutableArray alloc] init];
    ScoreData* scoreData = [[ScoreData alloc] init];
    for (int i = 0; i < encodedArray.count; i++) {
        scoreData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedArray[i]];
        [decodedObjects addObject:scoreData];
    }
    return decodedObjects;
}


#pragma Device Type/Size methods

- (int)deviceSize: (NSString*) callID{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([callID isEqualToString:BodyLeftWall]) {
            return self.frame.size.width - 100;
        }else if ([callID isEqualToString:BodyRightWall]) {
            return 100;
        }else if ([callID isEqualToString:SolidShelvePosition]) {
            return 170;
        }else if ([callID isEqualToString:HorizontalShelveGap]) {
            return 120;
        }
        
    } else {
        if ([callID isEqualToString:BodyLeftWall]) {
            return self.frame.size.width;
        }else if ([callID isEqualToString:BodyRightWall]) {
            return 1;
        }else if ([callID isEqualToString:SolidShelvePosition]) {
            return 370;
        }else if ([callID isEqualToString:HorizontalShelveGap]) {
            return 150;
        }
    }
    
    return 0;
}

#pragma Scene Creation Methods

-(void) playLevel{
    [self createBird];
    [self createCat];
    [self populateShelves];
    [self initAllActions];
    if (levelSelected < 2) {   // Fix this**
        [self moveForrestScene];
    }else if(levelSelected == 2){
        [self moveSpaceScene];
    }
    [self scoreLabel];
    [self moveBirdCat];
}

-(void) createIntro{
    titleBanner = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_TITLE];
    titleBanner.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height /2 - 5);
    [titleBanner setScale:1.2];
    titleBanner.zPosition = -15;
    [_moving addChild:titleBanner];
    
    playBtn = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(300, 100)];
    playBtn.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height / 2 );
    playBtn.zPosition = -14;
    [_moving addChild:playBtn];
    [self highScorelabel];
    
    _titleMove = [SKAction moveByX:0 y:-titleBanner.size.height * 2 duration:.1 * titleBanner.size.height*2];
}

-(void) createBird{
    //Bird displayed
    [self selectedBird];
    _bird = [SKSpriteNode spriteNodeWithTexture:birdTexture];
    
    //for now this will change*****************
    if ([GameData sharedGameData].birdSelected <= 1) {
        [_bird setScale:1.3];
    }else{
        [_bird setScale:.2];
    }
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 1.7);
    _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
    _bird.physicsBody.dynamic = YES;
    _bird.physicsBody.allowsRotation = NO;
    _bird.physicsBody.categoryBitMask = birdCategory;
    _bird.physicsBody.collisionBitMask = sidesCategory | floorCategory | shelvesCategory | shelvesFloorCategory | roofCategory | catCategory | chickCategory;
    _bird.physicsBody.contactTestBitMask = sidesCategory | floorCategory | shelvesCategory | shelvesFloorCategory | roofCategory | catCategory | chickCategory;
    [self addChild:_bird];
    [self addAccessories];
    
}

-(void) selectedBird{
    
    int selected = [GameData sharedGameData].birdSelected;
    if (selected <= 1) {
        birdTexture = SPRITES_TEX_ELLA;
        birdLeft = SPRITES_TEX_ELLALEFT;
        birdRight = SPRITES_TEX_ELLARIGHT;
        birdCrying = SPRITES_TEX_ELLACRYING;
        birdFight = LEVELSPRITES_ANIM_ELLAFIGHT;
    }else if(selected == 2){
        birdTexture =  BIRDSSPRITE_TEX_DEX;
        birdLeft = BIRDSSPRITE_TEX_DEXLEFT;
        birdRight = BIRDSSPRITE_TEX_DEXRIGHT;
        birdCrying = BIRDSSPRITE_TEX_DEXCRYING;
        birdFight = BIRDSSPRITE_ANIM_DEXFIGHT;
    }else if(selected == 3){
        birdTexture =  BIRDSSPRITE_TEX_HERB;
        birdLeft = BIRDSSPRITE_TEX_HERBLEFT;
        birdRight = BIRDSSPRITE_TEX_HERBRIGHT;
        birdCrying = BIRDSSPRITE_TEX_HERBCRYING;
        birdFight = BIRDSSPRITE_ANIM_HERBFIGHT;
    }
}

-(void) addAccessories{
    
    int selected = [GameData sharedGameData].birdSelected;
    int item = [GameData sharedGameData].accessorySelected;
    
    switch (selected) {
        case 1:
            [self ellaCustom:item];
            break;
        case 2:
            [self dexCustom:item];
            break;
        case 3:
            [self herbCustom:item];
            break;
            
        default:
            break;
    }
    
}

-(void) ellaCustom:(int) item{
    
    if (item == 1) {
        SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
        greenGlass.position = CGPointMake(0,-10);
        greenGlass.zPosition = 100;
        [_bird addChild:greenGlass];
    }else if(item == 2){
        SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
        purpleGlass.position = CGPointMake(0,-10);
        purpleGlass.zPosition = 100;
        [_bird addChild:purpleGlass];
    }else if (item == 3){
        SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
        redGlass.position = CGPointMake(0,-10);
        redGlass.zPosition = 100;
        [_bird addChild:redGlass];
    }else if (item == 4){
        SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
        mustach.position = CGPointMake(0,-20);
        mustach.zPosition = 100;
        [_bird addChild:mustach];
    }else if (item == 5){
        SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
        fancyGlass.position = CGPointMake(19,-10);
        fancyGlass.zPosition = 100;
        [_bird addChild:fancyGlass];
    }else if (item == 6){
        SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
        helmet.position = CGPointMake(0,19);
        helmet.zPosition = 100;
        [_bird addChild:helmet];
    }
    
}

-(void) dexCustom:(int) item{
    if (item == 1) {
        SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
        [greenGlass setScale:2.3];
        greenGlass.position = CGPointMake(-18,-29);
        greenGlass.zPosition = 100;
        [_bird addChild:greenGlass];
    }else if(item == 2){
        SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
        [purpleGlass setScale:7];
        purpleGlass.position = CGPointMake(-18,-29);
        purpleGlass.zPosition = 100;
        [_bird addChild:purpleGlass];
    }else if (item == 3){
        SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
        [redGlass setScale:7.5];
        redGlass.position = CGPointMake(-18,-29);
        redGlass.zPosition = 100;
        [_bird addChild:redGlass];
    }else if (item == 4){
        SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
        [mustach setScale:2.3];
        mustach.position = CGPointMake(-25,-110);
        mustach.zPosition = 100;
        [_bird addChild:mustach];
    }else if (item == 5){
        SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
        [fancyGlass setScale:7];
        fancyGlass.position = CGPointMake(160,-35);
        fancyGlass.zPosition = 100;
        [_bird addChild:fancyGlass];
    }else if (item == 6){
        SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
        [helmet setScale:7];
        helmet.position = CGPointMake(-20,180);
        helmet.zPosition = 100;
        [_bird addChild:helmet];
    }
}

-(void) herbCustom:(int) item{
    if (item == 1) {
        SKSpriteNode* greenGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_GREENGLASS];
        [greenGlass setScale:7];
        greenGlass.position = CGPointMake(-5,-18);
        greenGlass.zPosition = 100;
        [_bird addChild:greenGlass];
    }else if(item == 2){
        SKSpriteNode* purpleGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_PURPLEGLASS];
        [purpleGlass setScale:7];
        purpleGlass.position = CGPointMake(-5,-22);
        purpleGlass.zPosition = 100;
        [_bird addChild:purpleGlass];
    }else if (item == 3){
        SKSpriteNode* redGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_REDGLASS];
        [redGlass setScale:7.5];
        redGlass.position = CGPointMake(-5,-22);
        redGlass.zPosition = 100;
        [_bird addChild:redGlass];
    }else if (item == 4){
        SKSpriteNode* mustach = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_MUSTASH];
        [mustach setScale:7];
        mustach.position = CGPointMake(-10,-110);
        mustach.zPosition = 100;
        [_bird addChild:mustach];
    }else if (item == 5){
        SKSpriteNode* fancyGlass = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_FANCYGLASS];
        [fancyGlass setScale:7];
        fancyGlass.position = CGPointMake(120,-5);
        fancyGlass.zPosition = 100;
        [_bird addChild:fancyGlass];
    }else if (item == 6){
        SKSpriteNode* helmet = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_HELMET];
        [helmet setScale:7];
        helmet.position = CGPointMake(0,180);
        helmet.zPosition = 100;
        [_bird addChild:helmet];
    }
    
}


-(void) createCat{
    //Create Evil Cat
    _cat = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_CAT];
    [_cat setScale:1.3];
    _cat.position = CGPointMake(CGRectGetMidX(self.frame), 25);
    _cat.zPosition = 1;
    _cat.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_cat.size.height / 2];
    _cat.physicsBody.dynamic = YES;
    _cat.physicsBody.categoryBitMask = catCategory;
    _cat.physicsBody.collisionBitMask = sidesCategory | floorCategory;
    [self addChild:_cat];
}

-(void) createForrestScene{
    
    forrestScene = [forrestLevel createScene];
    forrestScene.position = CGPointMake(0, 0);
    _shevlesTexture = [forrestLevel shelveTexture];
    _background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    [_moving addChild:forrestScene];
}

-(void) createSpaceScene{
    
    spaceScene = [spaceLevel createSpaceScene];
    spaceScene.position = CGPointMake(0, 0);
    _shevlesTexture = [spaceLevel shelveTexture];
    _background = [SKColor colorWithRed:42.0/225.0 green:52.0/255.0 blue:56.0/255.0 alpha:1.0];
    [_moving addChild:spaceScene];
    
}

-(void) initAllActions{
    // Flap sound action
    _flapSound = [SKAction playSoundFileNamed:@"flap.mp3" waitForCompletion:NO];
    
    // Move bird to the right
    SKAction* birdMoveRight = [SKAction moveByX:_bird.size.width*2 y:0 duration:.003 * _bird.size.width*2];
    moveUntilCollisionR = [SKAction repeatActionForever:birdMoveRight];
    // Move bird to the left
    SKAction* birdMoveLeft = [SKAction moveByX:-_bird.size.width * 3 y:0 duration:.003 * _bird.size.width * 3];
    moveUntilCollisionL = [SKAction repeatActionForever:birdMoveLeft];
    
    SKAction* fightAnim = [SKAction animateWithTextures:birdFight timePerFrame:.1];
    _fight = [SKAction repeatActionForever:fightAnim];
        
    // Scale losing background, change font size and color
    scaleScoreBG = [SKAction scaleTo:3.5 duration:.1];
    losingScoreAnimation = [SKAction runBlock:(dispatch_block_t)^(){
        scoreBG.zPosition = 100;
        scoreBG.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidY(self.frame) + 50);
        scoreBG.fillColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _scoreLabelNode.fontSize = 100;
        _scoreLabelNode.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) - 100);
        _scoreLabelNode.zPosition = 101;
        _scoreLabelNode.fontColor = [UIColor grayColor];
        
        _highScoreLabelNode.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) - 180);
        _highScoreLabelNode.zPosition = 101;
    }];
    
    // Score feedback and animation
    bounceScoreLabel = [SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]];
    bounceScoreBG = [SKAction sequence:@[[SKAction scaleTo:0.8 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]];
}

// Creating a ground and sides physics container dummy which will be replaced once shelves are added
-(void) physicsContainer{
    
    SKNode* _leftSide = [SKNode node];
    _leftSide.position = CGPointMake([self deviceSize:BodyLeftWall], 1);
    _leftSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height * 2)];
    _leftSide.physicsBody.dynamic = NO;
    _leftSide.physicsBody.categoryBitMask = sidesCategory;
    
    SKNode* _rightSide = [SKNode node];
    _rightSide.position = CGPointMake([self deviceSize:BodyRightWall], 1);
    _rightSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height * 2)];
    _rightSide.physicsBody.dynamic = NO;
    _rightSide.physicsBody.categoryBitMask = sidesCategory;
    
    _dummyFloor = [SKNode node];
    _dummyFloor.position = CGPointMake(1, 1);
    _dummyFloor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    _dummyFloor.physicsBody.dynamic = NO;
    _dummyFloor.physicsBody.categoryBitMask = floorCategory;
    
    SKNode* _dummyRoof = [SKNode node];
    _dummyRoof.position = CGPointMake(1, self.frame.size.height);
    _dummyRoof.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    _dummyRoof.physicsBody.dynamic = NO;
    _dummyRoof.physicsBody.categoryBitMask = roofCategory;
    
    [self addChild:_leftSide];
    [self addChild:_rightSide];
    [self addChild:_dummyFloor];
    [self addChild:_dummyRoof];
}
//______________________________________________________________________________________________________

#pragma Shelves Methods

-(void) populateShelves{
    [self setShelvesMovement];
    for (int i = 1; i < 7; i++) {
        double shelvePosition = 180 * i;
        CGFloat fPosition = (CGFloat) shelvePosition;
        [self spawnShelves:NO yPosition:fPosition];
    }
    SKAction* initShelves = [SKAction performSelector:@selector(initShelves) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:initialDelay];
    [self runAction:[SKAction sequence:@[delay, initShelves]]];
}

-(void) setShelvesMovement{
    CGFloat distanceToMove = self.frame.size.height + 2 * _shevlesTexture.size.height;
    SKAction* moveShelves = [SKAction moveByX:0 y:-distanceToMove duration:0.03 * distanceToMove];
    SKAction* removeShelves = [SKAction removeFromParent];
    _moveAndRemoveShelves = [SKAction sequence:@[moveShelves, removeShelves]];
}

-(void) initShelves{
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnShelves:yPosition:) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:shelveDelay];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever withKey:@"spawnThenDelayForever"];
}

//-----------------------This method spawn shelves regularly-----------------------------------------
-(void) spawnShelves: (BOOL) started yPosition:(CGFloat) yPosition{
    
    shelveCount += 1;
    shelveCountChicks += 1;
    
    SKNode* shelvePair = [SKNode node];
    if (!started) { // Create the scene by adding shelves manually
        shelvePair.position = CGPointMake(0, yPosition);
    }else{ // once the scene is created, create shelves automotically
        shelvePair.position = CGPointMake(0, self.frame.size.height + _shevlesTexture.size.height * 2);
    }
    shelvePair.zPosition = 0;
    
    //Random number for the left shelve
    CGFloat x = [self randomFloatBetween:-400 and:50];

    SKSpriteNode* leftShelve = [SKSpriteNode spriteNodeWithTexture:_shevlesTexture];
    //[leftShelve setScale:2.0];
    
    if (((int)yPosition < 600 && (int)yPosition > 130) && !started) {
        leftShelve.position = CGPointMake([self deviceSize:SolidShelvePosition], 0);
    }else{
        leftShelve.position = CGPointMake(x, 0);
        
        //Adding score node after the solid shelves
        SKNode* scoreContactNode = [SKNode node];
        scoreContactNode.position = CGPointMake(x + leftShelve.size.width / 1.78, 60);
        scoreContactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(kHorizontalShelveGap, leftShelve.size.height)];
        scoreContactNode.physicsBody.categoryBitMask = scoreCategory;
        scoreContactNode.physicsBody.contactTestBitMask = birdCategory;
        scoreContactNode.physicsBody.dynamic = NO;
        [shelvePair addChild:scoreContactNode];
    }
    leftShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftShelve.size];
    leftShelve.physicsBody.dynamic = NO;
    leftShelve.physicsBody.categoryBitMask = shelvesCategory;
    [shelvePair addChild:leftShelve];
    
    SKSpriteNode* topOLeftShelve = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(leftShelve.size.width - 4, leftShelve.size.height /4)];
    topOLeftShelve.position = CGPointMake(x, 6.5);
    topOLeftShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topOLeftShelve.size];
    topOLeftShelve.physicsBody.categoryBitMask = shelvesFloorCategory;
    topOLeftShelve.physicsBody.dynamic = NO;
    [shelvePair addChild:topOLeftShelve]; // ** Maybe I need to change this to SKNode
    
    SKSpriteNode* rightShelve = [SKSpriteNode spriteNodeWithTexture:_shevlesTexture];
    rightShelve.position = CGPointMake(leftShelve.position.x + leftShelve.size.width + kHorizontalShelveGap, 0);
    rightShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightShelve.size];
    rightShelve.physicsBody.dynamic = NO;
    rightShelve.physicsBody.categoryBitMask = shelvesCategory;
    //[rightShelve setScale:2.0];
    [shelvePair addChild:rightShelve];

    SKSpriteNode* topORightShelve = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(rightShelve.size.width - 4, rightShelve.size.height /4)];
    topORightShelve.position = CGPointMake(x + leftShelve.size.width + kHorizontalShelveGap, 6.5);
    topORightShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topORightShelve.size];
    topORightShelve.physicsBody.categoryBitMask = shelvesFloorCategory;
    topORightShelve.physicsBody.dynamic = NO;
    [shelvePair addChild:topORightShelve];  // ** Maybe I need to change this to SKNode
    
    if (shelveCountChicks == 1 && started) { //Change here
        SKSpriteNode* chick = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_CHICK];
        chick.position = CGPointMake(140, 20); // Change this to update the chicks position
        chick.zPosition = 0;
        chick.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:chick.size.height / 2];
        chick.physicsBody.dynamic = NO;
        chick.physicsBody.categoryBitMask = chickCategory;
        [chicksReference addObject:chick];
        [shelvePair addChild:chick];
    }else if (shelveCountChicks > 6){
        shelveCountChicks = 0;
    }
    
    if (shelveCount == 3 && started) {
        SKSpriteNode* coin = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_STAR];
        coin.position = CGPointMake([self randomFloatBetween:150 and:600], 90);
        coin.name = @"coinTouched";
        coin.zPosition = 0;
        [coinsReference addObject:coin];
        [shelvePair addChild:coin];
    }else if (shelveCount > 3){
        shelveCount = 0;
    }
    
    [shelvesReference addObject:shelvePair];
    
    [shelvePair runAction:_moveAndRemoveShelves];
    
    [_shelves addChild:shelvePair];  // Addin to stop movement and reset scene;
}
//______________________________________________________________________________________________________

//-----------------------This method genrate random number for left shelve-----------------------------------------
- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

//______________________________________________________________________________________________________

#pragma Music Methods

-(void) playMusic: (NSString*) sound withLoop:(BOOL) loop{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:sound
                                         ofType:@"mp3"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    if (loop) {
        player.numberOfLoops = -1;
    }
    player.volume = .3;
    [player play];
}

#pragma Movement Methods

// Moves scene
-(void) moveForrestScene{
    // needs to be changed
    [titleBanner runAction:_titleMove withKey:@"BGAnim"];
    [playBtn runAction:_titleMove withKey:@"BGAnim"];
    [_highScoreLabelNode runAction:_titleMove withKey:@"BGAnim"];
    //____________________________
    [forrestLevel moveScene];
}

-(void) moveSpaceScene{
    // needs to be changed
    [titleBanner runAction:_titleMove withKey:@"BGAnim"];
    [playBtn runAction:_titleMove withKey:@"BGAnim"];
    [_highScoreLabelNode runAction:_titleMove withKey:@"BGAnim"];
    //____________________________
    [spaceLevel moveSpace];
    
}

//-----------------------Moves bird left to right--------------------------------------------------------
-(void) moveBirdCat{
    //adding motion to the bird
    if (!goingLeft) {
        if (!lost) {
            _bird.texture = birdLeft;
        }
        [_bird removeActionForKey:@"birdMoving"];
        [_bird runAction:moveUntilCollisionR withKey:@"birdMoving"];
        [_cat removeActionForKey:@"catMoving"];
        [_cat runAction:moveUntilCollisionR withKey:@"catMoving"];
        goingLeft = true;
    }else{
        if (!lost) {
            _bird.texture = birdRight;
        }
        [_bird removeActionForKey:@"birdMoving"];
        [_bird runAction:moveUntilCollisionL withKey:@"birdMoving"];
        [_cat removeActionForKey:@"catMoving"];
        [_cat runAction:moveUntilCollisionL withKey:@"catMoving"];
        goingLeft = false;
    }
}
//______________________________________________________________________________________________________

#pragma HUD Methods

-(void) createHeader{
    
    SKSpriteNode* headerBG = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(self.frame.size.width, 80)];
    headerBG.position = CGPointMake(290, self.frame.size.height / 1.04 );
    headerBG.zPosition = 100;
    headerBG.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:headerBG.size];
    headerBG.physicsBody.dynamic = NO;
    headerBG.physicsBody.categoryBitMask = roofCategory;
    if (levelSelected == 2) {
        headerBG.color = [UIColor whiteColor];
    }
    [self addChild:headerBG];
    
    SKSpriteNode* headerCoin = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_STAR];
    headerCoin.position = CGPointMake(140, self.frame.size.height / 1.04);
    headerCoin.zPosition = 101;
    [self addChild:headerCoin];
    
    coinsCollectedLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    coinsCollectedLabel.fontColor = [UIColor whiteColor];
    if (levelSelected == 2) {
        coinsCollectedLabel.fontColor = [UIColor grayColor];
    }
    coinsCollectedLabel.fontSize = 60;
    coinsCollectedLabel.position = CGPointMake(headerCoin.position.x + headerCoin.size.width + 30, self.frame.size.height / 1.065);
    coinsCollectedLabel.zPosition = 101;
    coinsCollectedLabel.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].coinsCollected];
    [self addChild:coinsCollectedLabel];
    
    SKSpriteNode* headerChick = [SKSpriteNode spriteNodeWithTexture:BIRDSSPRITE_TEX_CHICK];
    headerChick.position = CGPointMake(500, self.frame.size.height / 1.04);
    headerChick.zPosition = 101;
    [headerChick setScale:1.6];
    [self addChild:headerChick];
    
    chicksCollectedLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    chicksCollectedLabel.fontColor = [UIColor whiteColor];
    if (levelSelected == 2) {
        chicksCollectedLabel.fontColor = [UIColor grayColor];
    }
    chicksCollectedLabel.fontSize = 60;
    chicksCollectedLabel.position = CGPointMake(headerChick.position.x + headerChick.size.width + 30, self.frame.size.height / 1.065);
    chicksCollectedLabel.zPosition = 101;
    chicksCollectedLabel.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].chicksCollected];
    [self addChild:chicksCollectedLabel];
    
    
    [self addChild:[self pauseBtnNode]];
}

- (SKSpriteNode *)pauseBtnNode{
    pauseNode = [SKSpriteNode spriteNodeWithImageNamed:@"pauseBtn"];
    [pauseNode setScale:.9];
    pauseNode.position = CGPointMake(CGRectGetMidX( self.frame ), self.frame.size.height / 1.04 );
    pauseNode.name = @"pauseBtn";//how the node is identified later
    pauseNode.zPosition = 101;
    
    return pauseNode;
}

-(void) scoreLabel{
    
    scoreBG = [SKShapeNode shapeNodeWithCircleOfRadius:80];
    scoreBG.fillColor = [UIColor colorWithWhite:0.2f alpha:0.65f];
    scoreBG.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidY(self.frame) + 250);
    scoreBG.name = @"restart";
    scoreBG.zPosition = -2;
    
    // Initialize label and create a label which holds the score
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    _scoreLabelNode.fontColor = [UIColor whiteColor];
    _scoreLabelNode.fontSize = 100;
    _scoreLabelNode.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) - 39);
    _scoreLabelNode.zPosition = -1;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [self addChild:_scoreLabelNode];
    [self addChild:scoreBG];

}

-(void) highScorelabel{
    
    _highScoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    _highScoreLabelNode.fontColor = [UIColor grayColor];
    _highScoreLabelNode.fontSize = 40;
    _highScoreLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height /2.1);
    _highScoreLabelNode.zPosition = -1;
    _highScoreLabelNode.text = [NSString stringWithFormat:@"High Score: %li", [GameData sharedGameData].highScore];
    [_moving addChild:_highScoreLabelNode];
}

-(void) losingLabel{
    
    restartLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    restartLabel.fontColor = [UIColor grayColor];
    restartLabel.fontSize = 40;
    restartLabel.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame));
    restartLabel.zPosition = 101;
    restartLabel.text= @"Tap to Restart";
    [self addChild:restartLabel];
    
    gameOver = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    gameOver.fontColor = [UIColor grayColor];
    gameOver.fontSize = 85;
    gameOver.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) - 150 );
    gameOver.zPosition = 101;
    gameOver.text = @"Game Over!";
    [self addChild:gameOver];
    
    [scoreBG runAction:scaleScoreBG];
    
    _scoreLabelNode.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
    _highScoreLabelNode.text = [NSString stringWithFormat:@"High: %li", [GameData sharedGameData].highScore];
    [scoreBG runAction:losingScoreAnimation];
}

-(void) pauseGame{
    if(!_sceneSize.paused){
        pauseNode.texture = [SKTexture textureWithImageNamed:@"unpause"];
        [player pause];
        _sceneSize.paused = YES;
        
    }else{
        _sceneSize.paused = NO;
        [player play];
        pauseNode.texture = [SKTexture textureWithImageNamed:@"pauseBtn"];
    }
}


#pragma Touch and Collision detection

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];
    
    if(_moving.speed > 0 && [node.name isEqualToString:@"coinTouched"]){
        
        int i = 0;
        while (i < coinsReference.count) {
            SKSpriteNode* tappedCoin = coinsReference[i];
            
            if (tappedCoin.position.x == node.position.x) {
                [tappedCoin removeFromParent];
                [coinsReference removeObject:tappedCoin];
                [GameData sharedGameData].coinsCollected += 1;
                coinsCollectedLabel.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].coinsCollected];
            }
            i++;
        }
        
    }else if (_moving.speed > 0) {
        if ([node.name isEqualToString:@"pauseBtn"]) {
            [self pauseGame];
        }else{
            // Tap to jump
            if (flapCount < 2) {
                _bird.physicsBody.velocity = CGVectorMake(0, 0);
                [_bird.physicsBody applyImpulse:CGVectorMake(0, 120)];
                [self runAction:_flapSound];
                flapCount++;
            }
        }
    }else if([node.name isEqualToString:@"back"]){
        
        SKView * skView = (SKView *)self.view;
        
        MainMenu *scene = [MainMenu unarchiveFromFile:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        [player stop];
        [self removeAllChildren];
        // Present the scene.
        [skView presentScene:scene transition:[SKTransition crossFadeWithDuration: .5]];
        
    }else if (lost){ //Lost game
        if ([node.name isEqualToString:@"restart"]) {
            [self resetScene];
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    if ((contact.bodyA.categoryBitMask & sidesCategory) == sidesCategory || (contact.bodyB.categoryBitMask & sidesCategory) == sidesCategory) { // When bird hits side
        
        [self moveBirdCat];
       
    }else if ((contact.bodyA.categoryBitMask & shelvesFloorCategory) == shelvesFloorCategory || (contact.bodyB.categoryBitMask & shelvesFloorCategory) == shelvesFloorCategory){ // when bird hits top of shelve
        flapCount = 0; // resets the flap count only when the floor is touched so that the bird can only jump twice
    }else if ( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
        // Bird has contact with score entity
        // Checking the shelves refrence to count up the score only for jumping new shelves
        int i = 0;
        while (i < shelvesReference.count) {
            SKNode* currentShelve = shelvesReference[i];
            if (currentShelve.position.y < 0) {
                [shelvesReference removeObject:currentShelve];
            }else{
                if (currentShelve.children.count > 4) {
                    if (currentShelve.position.y < _bird.position.y) {
                        [GameData sharedGameData].score += 1;
                        _scoreLabelNode.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
                        [_scoreLabelNode runAction:bounceScoreLabel];
                        [scoreBG runAction:bounceScoreBG];
                        [self updateAchievements:@"scoreIncrease"];
                        [shelvesReference removeObject:currentShelve];
                    }else{
                        i++;
                    }
                }else{
                    i++;
                }
            }
        }
    }else if(( contact.bodyA.categoryBitMask & catCategory) == catCategory || ( contact.bodyB.categoryBitMask & catCategory) == catCategory){
        
        [GameData sharedGameData].highScore = MAX([GameData sharedGameData].score,
                                                    [GameData sharedGameData].highScore); //Updating the highscore if the current score is higher
        [[GameData sharedGameData] save];  // Save all changes to the sharedGameData
        
        //Score checking and reporting to game center----------
        
        ScoreData* highScoreObject = [[ScoreData alloc] init];
        highScoreObject.alies = [[NSUserDefaults standardUserDefaults] valueForKey:@"alies"];
        highScoreObject.score = (int)[GameData sharedGameData].score;
        
        NSData* highScoreData = [NSKeyedArchiver archivedDataWithRootObject:highScoreObject];
        [[NSUserDefaults standardUserDefaults] setObject:highScoreData forKey:@"highscore"];
        
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
            [self reportScore]; //Reports score to Game Center
        }
        
        //------------------------------------------------------
        if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]) { //Checks if the saved array is empty
            scoresArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]; //assigns saved array to                      scoresArray
        }
        ScoreData* scoreData = [[ScoreData alloc] init]; // Creates a new object
        scoreData.username = username;
        scoreData.alies = [[NSUserDefaults standardUserDefaults] valueForKey:@"gcalies"];
        scoreData.score = (int)[GameData sharedGameData].score;
        scoreData.date = [self currentDate];
        
        NSData* scoreDataObject = [NSKeyedArchiver archivedDataWithRootObject:scoreData]; // Encodes the object and creates an NSData out of it
        [scoresArray addObject:scoreDataObject]; // Add nsdata object to mutable array
        
        NSArray* scoresToSave = scoresArray; // Assign mutable array to nsarray since we can't save mutable arrays to userdefaults
        
        [[NSUserDefaults standardUserDefaults] setObject: scoresToSave forKey:@"scores"]; // Save the nsarray
        [[NSUserDefaults standardUserDefaults] synchronize]; //synchronize the data
        
        [self updateAchievements:@"gameEnded"]; //Updating achievements

        [player stop]; // Stop the music
        [self playMusic:@"losing" withLoop:NO]; // Play losing sound
        if (_moving.speed > 0) {
            _moving.speed = 0; // Stop the scene from moving
            [_bird removeActionForKey:@"birdMoving"]; // Remove bird movement action
            [self removeActionForKey:@"spawnThenDelayForever"]; // Remove shevles spawning action
            [self losingLabel]; // Display losing label
            pauseNode.texture = [SKTexture textureWithImageNamed:@"backMain"]; // Update the pause button to the back button
            pauseNode.name = @"back"; // update the pause node name
            [[GameData sharedGameData] reset]; // Reseting the score
        }
        lost = true; // Setting current status of the game
        
        [_bird removeActionForKey:@"crying"]; // Remvoing crying action of the bird
        [_bird removeActionForKey:@"birdMoving"]; // Not sure why this is here again, check back**
        [self startFight]; // Start fight animation

    }else if(( contact.bodyA.categoryBitMask & chickCategory) == chickCategory || ( contact.bodyB.categoryBitMask & chickCategory) == chickCategory){
        
        int i = 0;
        while (i < chicksReference.count) {
            SKSpriteNode* currentChick = chicksReference[i];
            if (currentChick.position.y < 0) {
                [chicksReference removeObject:currentChick];
            }else{
                
                if (currentChick.position.y < _bird.position.y + 30) {
                    [GameData sharedGameData].chicksCollected += 1;
                    chicksCollectedLabel.text = [NSString stringWithFormat:@"%ld", [GameData sharedGameData].chicksCollected];
                    [chicksReference removeObject:currentChick];
                    [currentChick removeFromParent];
                    //More customization here
                }else{
                    i++;
                }
            }
        }
    }
}

-(NSString*) currentDate{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSString* scoreDate = [NSString stringWithFormat:@"%ld, %ld, %ld", (long)day, (long)month, (long)year];

    return scoreDate;
}

-(void)reportScore{
    
   GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier: @"leader_1.0"];
    ScoreData* decodedHighScore = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"]];
    
    if ([decodedHighScore.alies isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"gcalies"]]) {
        score.value = decodedHighScore.score; // push highscore to GC
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
    
}

-(void) startFight{
    
    [_cat removeFromParent];
    [_bird removeAllChildren];
    [_bird runAction:_fight withKey:@"fightScene"];
    //for now this will change*****************
    if ([GameData sharedGameData].birdSelected <= 1) {
        [_bird setScale:2.5];
    }else{
        [_bird setScale:.5];
    }
}

#pragma Reset Scene

-(void) resetBackGround{
    titleBanner.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height /2 - 5);
    [titleBanner removeActionForKey:@"BGAnim"];
    playBtn.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height / 2 );
    [playBtn removeActionForKey:@"BGAnim"];
    [_highScoreLabelNode removeActionForKey:@"BGAnim"];
}


-(void) resetScene{
    
    // Moving bird to original position
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 1.7);
    _bird.physicsBody.velocity = CGVectorMake(0, 0);
    
    //for now this will change*****************
    if ([GameData sharedGameData].birdSelected <= 1) {
        [_bird setScale:1.3];
    }else{
        [_bird setScale:.2];
    }
    [self addAccessories];
    [_bird removeActionForKey:@"fightScene"];
    [_bird removeActionForKey:@"crying"];
    
    [self createCat];
    
    // Reseting the scene
    if (levelSelected < 2) {
        [forrestLevel resetMovement];
        [forrestScene removeFromParent];
        forrestScene = [forrestLevel createScene];
        [_moving addChild:forrestScene];
        [self resetBackGround]; // remove after method is updated
        [self moveForrestScene];
    }else if(levelSelected == 2){
        [spaceLevel resetMovement];
        [spaceScene removeFromParent];
        spaceScene = [spaceLevel createSpaceScene];
        [_moving addChild:spaceScene];
        [self resetBackGround]; // remove after method is updated
        [self moveSpaceScene];
    }
    
    // Removing all shelves to repopulate screen
    // Clearing all refrences
    [_shelves removeAllChildren];
    [shelvesReference removeAllObjects];
    [coinsReference removeAllObjects];
    shelveCount = 0;
    shelveCountChicks = 0;
    
    // Reset game status
    lost = false;
    
    // Moving the world again
    _moving.speed = worldSpeed;
    
    // remove lose label and recreating score label
    [_scoreLabelNode removeFromParent];
    [_highScoreLabelNode removeFromParent];
    [scoreBG removeFromParent];
    [gameOver removeFromParent];
    [restartLabel removeFromParent];
    [self scoreLabel];
    [self highScorelabel];
    [_highScoreLabelNode runAction:_titleMove];
    pauseNode.texture = [SKTexture textureWithImageNamed:@"pauseBtn"];
    pauseNode.name = @"pauseBtn";

    flapCount = 0; // This needs to be changed**
    
    // Stop losing music to play the game background music
    [player stop];
    [self playMusic:@"BGMusic" withLoop:YES];
    
    // Recreate shelves
    [self populateShelves];
    
    // Start bird movement
    [self moveBirdCat];
    
    // Reset bird texture
    _bird.texture = birdTexture;
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Start crying animation when close to losing
    
    if (!lost) {
        if (_bird.position.y < 300) {
            _bird.texture = birdCrying;
        }else{
            //_bird.texture = birdTexture;
        }
    }
}

@end
