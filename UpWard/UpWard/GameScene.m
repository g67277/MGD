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
#import "SpaceLevelSprite.h"
#import "GameViewController.h"
@import GameKit;

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface GameScene()

    -(void)reportScore;
@end

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
    
    //Testing
    username = @"Nazir";
    scoresArray = [[NSMutableArray alloc] init];
    incomingScoresArray = [[NSMutableArray alloc] init];
    

    /* Setup your scene here */
    //Game Setup
    [self getLeaderIdentifier];

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
    
    //Creating the shelves texture here
    if (levelSelected < 2) {
        _mountShevlesTexture = [SKTexture textureWithImageNamed:@"mountShelve"];
    }else{
        _mountShevlesTexture = [SKTexture textureWithImageNamed:@"spaceShelve"];
    }
    
    _moving = [SKNode node];
    [self addChild:_moving];
    //Speed of the game
    _moving.speed = worldSpeed;
    _shelves = [SKNode node];
    [_moving addChild:_shelves];
    [self playMusic:@"BGMusic" withLoop:YES];
    //Adding the container
    [self physicsContainer];
    //Creating the shelves texture here
    if (levelSelected < 2) {
        _background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
        _mountShevlesTexture = [SKTexture textureWithImageNamed:@"mountShelve"];
        [self createForrestScene];
    }else{
        _background = [SKColor colorWithRed:42.0/225.0 green:52.0/255.0 blue:56.0/255.0 alpha:1.0];
        _mountShevlesTexture = [SKTexture textureWithImageNamed:@"spaceShelve"];
        [self createSpaceScene];
    }
    [self createHeader];
    [self createIntro];
    [self playLevel];
    
    //Background for the level
    self.backgroundColor = _background;
}

-(void) getLeaderIdentifier{
    if ([GKLocalPlayer localPlayer].authenticated) {
        
        NSLog(@"%@", [GKLocalPlayer localPlayer].alias); // Name to display in local leaderboard

        
        // Get the default leaderboard identifier.
        [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
            
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else{
                _leaderboardIdentifier = leaderboardIdentifier;
                NSLog(@"%@", _leaderboardIdentifier);
            }
        }];
    }
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
    //Parallax background
    //Grass background
    grass = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:98/255.0f green:204/255.0f blue:103/255.0f alpha:1.0f] size:CGSizeMake(self.frame.size.width, self.frame.size.height / 1.5)];
    grass.position = CGPointMake(grass.size.width /2 , grass.size.height / 2);
    grass.zPosition = -100;
    [_moving addChild:grass];
    
    SKAction* grassMove = [SKAction moveByX:0 y: -grass.size.height * 2 duration:1.0 * grass.size.height * 2];
    keepGM = [SKAction repeatActionForever:grassMove];
    
    //Front tree
    frontTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_FIRSTTREE];
    frontTree.position = CGPointMake(90, frontTree.size.height /2 );
    frontTree.zPosition = -14;
    [_moving addChild:frontTree];
    
    SKAction* frontTreeMove = [SKAction moveByX:-frontTree.size.width y: -frontTree.size.height * 2 duration:.3 * frontTree.size.height * 2];
    keepFTM = [SKAction repeatActionForever:frontTreeMove];
    
    //Left Tree
    leftTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_LEFTTREE];
    leftTree.position = CGPointMake(self.frame.size.width / 1.2, leftTree.size.height / 2 - 5);
    leftTree.zPosition = -20;
    [_moving addChild:leftTree];
    
    SKAction* leftTreeMove = [SKAction moveByX:leftTree.size.width / 2 y: -leftTree.size.height * 2 duration:.2 * leftTree.size.height * 2];
    keepLTM = [SKAction repeatActionForever:leftTreeMove];
    
    //Right Tree
    rightTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_RIGHTTREE];
    rightTree.position = CGPointMake(120, rightTree.size.height / 1.7);
    rightTree.zPosition = -20;
    [_moving addChild:rightTree];
    
    SKAction* rightTreeMove = [SKAction moveByX:-rightTree.size.width / 2 y: -rightTree.size.height * 2 duration:.2 * rightTree.size.height * 2];
    keepRTM = [SKAction repeatActionForever:rightTreeMove];
    
    //Right Mid Tree
    rightMidTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_RIGHTMIDTREE];
    rightMidTree.position = CGPointMake(250, rightMidTree.size.height);
    rightMidTree.zPosition = -19;
    [_moving addChild:rightMidTree];
    
    SKAction* rightMidTreeMove = [SKAction moveByX:-rightMidTree.size.width / 3 y: -rightMidTree.size.height * 2 duration:.4 * rightMidTree.size.height * 2];
    keepRMTM = [SKAction repeatActionForever:rightMidTreeMove];
    
    //Left Mid Tree
    leftMidTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_LEFTMIDTREE];
    leftMidTree.position = CGPointMake(self.frame.size.width / 1.6, leftMidTree.size.height);
    leftMidTree.zPosition = -22;
    [_moving addChild:leftMidTree];
    
    SKAction* leftMidTreeMove = [SKAction moveByX:leftMidTree.size.width / 3 y: -leftMidTree.size.height * 2 duration:.4 * leftMidTree.size.height * 2];
    keepLMTM = [SKAction repeatActionForever:leftMidTreeMove];
    
    //Mid Tree
    midTree = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_MIDTREE];
    midTree.position = CGPointMake(self.size.width / 2, midTree.size.height * 1.13);
    midTree.zPosition = -18;
    [_moving addChild:midTree];
    
    SKAction* midTreeMove = [SKAction moveByX:0 y: -midTree.size.height * 2 duration:.4 * midTree.size.height * 2];
    keepMTM = [SKAction repeatActionForever:midTreeMove];
    
    //Background trees
    bGTrees = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_BACKGROUNDTREES];
    [bGTrees setScale:1.1];
    bGTrees.position = CGPointMake(430, bGTrees.size.height * 2);
    bGTrees.zPosition = -25;
    [_moving addChild:bGTrees];
    
    //Lake
    lake = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_LAKE];
    lake.position = CGPointMake(self.size.width / 2, lake.size.height * 4.8);
    lake.zPosition = -40;
    [_moving addChild:lake];
    
    SKAction* bGTreesNLake = [SKAction moveByX:0 y: -bGTrees.size.height * 2 duration:.4 * bGTrees.size.height * 2];
    keepBGTL = [SKAction repeatActionForever:bGTreesNLake];
    
    //small Mountains
    smallMount1 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_SMALLMOUNTAIN];
    smallMount1.position = CGPointMake(self.size.width / 2, smallMount1.size.height * 3.8);
    smallMount1.zPosition = -30;
    [_moving addChild:smallMount1];
    
    SKAction* smallMount1Move = [SKAction moveByX:0 y: -smallMount1.size.height * 2 duration:.4 * smallMount1.size.height * 2];
    keepSM1 = [SKAction repeatActionForever:smallMount1Move];
    
    smallMount2 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_SMALLMOUNTAIN];
    smallMount2.position = CGPointMake(smallMount2.size.width / 4, smallMount1.size.height * 3.8);
    smallMount2.zPosition = -31;
    [_moving addChild:smallMount2];
    
    SKAction* smallMount2Move = [SKAction moveByX:0 y: -smallMount1.size.height * 2 duration:.45 * smallMount1.size.height * 2];
    keepSM2 = [SKAction repeatActionForever:smallMount2Move];
    
    smallMount3 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_SMALLMOUNTAIN];
    smallMount3.position = CGPointMake(smallMount3.size.width, smallMount1.size.height * 3.8);
    smallMount3.zPosition = -31;
    [_moving addChild:smallMount3];
    
    SKAction* smallMount3Move = [SKAction moveByX:0 y: -smallMount1.size.height * 2 duration:.43 * smallMount1.size.height * 2];
    keepSM3 = [SKAction repeatActionForever:smallMount3Move];
    
    //Large mountains
    largeMount1 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_BIGMOUNTAIN];
    largeMount1.position = CGPointMake(self.frame.size.width / 1.4, smallMount1.size.height * 5);
    largeMount1.zPosition = -34;
    [_moving addChild:largeMount1];
    
    SKAction* largeMount1Move = [SKAction moveByX:0 y: -largeMount1.size.height * 2 duration:.5 * largeMount1.size.height * 2];
    keepLM1 = [SKAction repeatActionForever:largeMount1Move];
    
    largeMount2 = [SKSpriteNode spriteNodeWithTexture:LEVELSPRITES_TEX_BIGMOUNTAIN];
    [largeMount2 setScale:.8];
    largeMount2.position = CGPointMake(self.frame.size.width / 3, smallMount1.size.height * 5);
    largeMount2.zPosition = -35;
    [_moving addChild:largeMount2];
    
    SKAction* largeMount2Move = [SKAction moveByX:0 y: -largeMount1.size.height * 2 duration:.55 * largeMount1.size.height * 2];
    keepLM2 = [SKAction repeatActionForever:largeMount2Move];
    
}

-(void) createSpaceScene{
    
    SKTexture* starsTextures = [SKTexture textureWithImageNamed:@"starsBG"];
    starsBG = [SKSpriteNode spriteNodeWithTexture: starsTextures];
    [starsBG setScale:.9];
    starsBG.position = CGPointMake(CGRectGetMidX(self.frame), 10);
    starsBG.zPosition = -50;
    [_moving addChild:starsBG];
    
    SKAction* starsMove = [SKAction moveByX:0 y:-starsBG.size.height + 200 duration:2 * starsBG.size.height];
    keepStars = [SKAction repeatActionForever:starsMove];
    
    saturn = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_SATURN];
    [saturn setScale:.8];
    saturn.position = CGPointMake(600, 500);
    saturn.zPosition = -30;
    [_moving addChild:saturn];
    
    SKAction* saturnMove = [SKAction moveByX:80 y:-saturn.size.height * 2 duration:.55 * saturn.size.height * 2];
    keepSaturn = [SKAction repeatActionForever:saturnMove];
    
    jupiter = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_JUPITER];
    [jupiter setScale:.8];
    jupiter.position = CGPointMake(200, 1000);
    jupiter.zPosition = -29;
    [_moving addChild:jupiter];
    
    SKAction* jupiterMove = [SKAction moveByX:-180 y:-jupiter.size.height * 2 duration:.55 * jupiter.size.height * 2];
    keepJupiter = [SKAction repeatActionForever:jupiterMove];
    
    venus = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_VENUS];
    [venus setScale:.8];
    venus.position = CGPointMake(300, 1300);
    venus.zPosition = -29;
    [_moving addChild:venus];
    
    SKAction* venusMove = [SKAction moveByX:0 y:-venus.size.height * 2 duration:.55 * venus.size.height * 2];
    keepVenus = [SKAction repeatActionForever:venusMove];
    
    neptune = [SKSpriteNode spriteNodeWithTexture:SPACELEVEL_TEX_NEPTUNE];
    [neptune setScale:.8];
    neptune.position = CGPointMake(100, 1600);
    neptune.zPosition = -29;
    [_moving addChild:neptune];
    
    SKAction* neptuneMove = [SKAction moveByX:-180 y:-neptune.size.height * 2 duration:.55 * neptune.size.height * 2];
    keepNeptune = [SKAction repeatActionForever:neptuneMove];
    
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
    
    _leftSide = [SKNode node];
    _leftSide.position = CGPointMake([self deviceSize:BodyLeftWall], 1);
    _leftSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height * 2)];
    _leftSide.physicsBody.dynamic = NO;
    _leftSide.physicsBody.categoryBitMask = sidesCategory;
    
    _rightSide = [SKNode node];
    _rightSide.position = CGPointMake([self deviceSize:BodyRightWall], 1);
    _rightSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, self.frame.size.height * 2)];
    _rightSide.physicsBody.dynamic = NO;
    _rightSide.physicsBody.categoryBitMask = sidesCategory;
    
    _dummyFloor = [SKNode node];
    _dummyFloor.position = CGPointMake(1, 1);
    _dummyFloor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    _dummyFloor.physicsBody.dynamic = NO;
    _dummyFloor.physicsBody.categoryBitMask = floorCategory;
    
    _dummyRoof = [SKNode node];
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
    CGFloat distanceToMove = self.frame.size.height + 2 * _mountShevlesTexture.size.height;
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
    
    shelvePair = [SKNode node];
    if (!started) { // Create the scene by adding shelves manually
        shelvePair.position = CGPointMake(0, yPosition);
    }else{ // once the scene is created, create shelves automotically
        shelvePair.position = CGPointMake(0, self.frame.size.height + _mountShevlesTexture.size.height * 2);
    }
    shelvePair.zPosition = 0;
    
    //Random number for the left shelve
    CGFloat x = [self randomFloatBetween:-400 and:50];

    SKSpriteNode* leftShelve = [SKSpriteNode spriteNodeWithTexture:_mountShevlesTexture];
    //[leftShelve setScale:2.0];
    
    if (((int)yPosition < 600 && (int)yPosition > 130) && !started) {
        leftShelve.position = CGPointMake([self deviceSize:SolidShelvePosition], 0);
    }else{
        leftShelve.position = CGPointMake(x, 0);
        
        //Adding score node after the solid shelves
        scoreContactNode = [SKNode node];
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
    
    SKSpriteNode* rightShelve = [SKSpriteNode spriteNodeWithTexture:_mountShevlesTexture];
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
    
    [titleBanner runAction:_titleMove withKey:@"BGAnim"];
    [playBtn runAction:_titleMove withKey:@"BGAnim"];
    [frontTree runAction:keepFTM withKey:@"BGAnim"];
    [leftTree runAction:keepLTM withKey:@"BGAnim"];
    [rightTree runAction:keepRTM withKey:@"BGAnim"];
    [rightMidTree runAction:keepRMTM withKey:@"BGAnim"];
    [leftMidTree runAction:keepLMTM withKey:@"BGAnim"];
    [midTree runAction:keepMTM withKey:@"BGAnim"];
    [bGTrees runAction:keepBGTL withKey:@"BGAnim"];
    [lake runAction:keepBGTL withKey:@"BGAnim"];
    [smallMount1 runAction:keepSM1 withKey:@"BGAnim"];
    [smallMount2 runAction:keepSM2 withKey:@"BGAnim"];
    [smallMount3 runAction:keepSM3 withKey:@"BGAnim"];
    [largeMount1 runAction:keepLM1 withKey:@"BGAnim"];
    [largeMount2 runAction:keepLM2 withKey:@"BGAnim"];
    [grass runAction:keepGM withKey:@"BGAnim"];
    [_highScoreLabelNode runAction:_titleMove withKey:@"BGAnim"];
}

-(void) moveSpaceScene{
    
    [titleBanner runAction:_titleMove withKey:@"BGAnim"];
    [playBtn runAction:_titleMove withKey:@"BGAnim"];
    [_highScoreLabelNode runAction:_titleMove withKey:@"BGAnim"];
    [starsBG runAction:keepStars withKey:@"BGAnim"];
    [saturn runAction:keepSaturn withKey:@"BGAnim"];
    [venus runAction:keepVenus withKey:@"BGAnim"];
    [jupiter runAction:keepJupiter withKey:@"BGAnim"];
    [neptune runAction:keepNeptune withKey:@"BGAnim"];
    
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
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
            [self reportScore]; //Reports score to Game Center
        }
        
        
        if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]) { //Checks if the saved array is empty
            scoresArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]; //assigns saved array to                      scoresArray
        }
        ScoreData* scoreData = [[ScoreData alloc] init]; // Creates a new object
        scoreData.username = username;
        scoreData.score = (int)[GameData sharedGameData].score;
        scoreData.date = [self currentDate];
        
        NSData* scoreDataObject = [NSKeyedArchiver archivedDataWithRootObject:scoreData]; // Encodes the object and creates an NSData out of it
        [scoresArray addObject:scoreDataObject]; // Add nsdata object to mutable array
        
        NSArray* scoresToSave = scoresArray; // Assign mutable array to nsarray since we can't save mutable arrays to userdefaults
        
        [[NSUserDefaults standardUserDefaults] setObject: scoresToSave forKey:@"scores"]; // Save the nsarray
        [[NSUserDefaults standardUserDefaults] synchronize]; //synchronize the data
        
        
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
    NSLog(@"%ld, %ld, %ld", (long)day, (long)month, (long)year);
    NSString* scoreDate = [NSString stringWithFormat:@"%ld, %ld, %ld", (long)day, (long)month, (long)year];

    return scoreDate;
}

-(void)reportScore{
    
   GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier: _leaderboardIdentifier];
    score.value = [GameData sharedGameData].highScore; // push highscore to GC
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
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
    grass.position = CGPointMake(grass.size.width /2 , grass.size.height / 2);
    [grass removeActionForKey:@"BGAnim"];
    frontTree.position = CGPointMake(90, frontTree.size.height /2 );
    [frontTree removeActionForKey:@"BGAnim"];
    leftTree.position = CGPointMake(self.frame.size.width / 1.2, leftTree.size.height / 2 - 5);
    [leftTree removeActionForKey:@"BGAnim"];
    rightTree.position = CGPointMake(120, rightTree.size.height / 1.7);
    [rightTree removeActionForKey:@"BGAnim"];
    rightMidTree.position = CGPointMake(250, rightMidTree.size.height);
    [rightMidTree removeActionForKey:@"BGAnim"];
    leftMidTree.position = CGPointMake(self.frame.size.width / 1.6, leftMidTree.size.height);
    [leftMidTree removeActionForKey:@"BGAnim"];
    midTree.position = CGPointMake(self.size.width / 2, midTree.size.height * 1.13);
    [midTree removeActionForKey:@"BGAnim"];
    bGTrees.position = CGPointMake(430, bGTrees.size.height * 2);
    [bGTrees removeActionForKey:@"BGAnim"];
    lake.position = CGPointMake(self.size.width / 2, lake.size.height * 4.8);
    [lake removeActionForKey:@"BGAnim"];
    smallMount1.position = CGPointMake(self.size.width / 2, smallMount1.size.height * 3.8);
    [smallMount1 removeActionForKey:@"BGAnim"];
    smallMount2.position = CGPointMake(smallMount2.size.width / 4, smallMount1.size.height * 3.8);
    [smallMount2 removeActionForKey:@"BGAnim"];
    smallMount3.position = CGPointMake(smallMount3.size.width, smallMount1.size.height * 3.8);
    [smallMount3 removeActionForKey:@"BGAnim"];
    largeMount1.position = CGPointMake(self.frame.size.width / 1.4, smallMount1.size.height * 5);
    [largeMount1 removeActionForKey:@"BGAnim"];
    largeMount2.position = CGPointMake(self.frame.size.width / 3, smallMount1.size.height * 5);
    [largeMount2 removeActionForKey:@"BGAnim"];
    
}

-(void) resetSpaceBackground{
    titleBanner.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height /2 - 5);
    [titleBanner removeActionForKey:@"BGAnim"];
    playBtn.position = CGPointMake(CGRectGetMidX(self.frame), titleBanner.size.height / 2 );
    [playBtn removeActionForKey:@"BGAnim"];
    [_highScoreLabelNode removeActionForKey:@"BGAnim"];
    
    
    starsBG.position = CGPointMake(CGRectGetMidX(self.frame), 10);
    [starsBG removeActionForKey:@"BGAnim"];
    
    saturn.position = CGPointMake(600, 500);
    [saturn removeActionForKey:@"BGAnim"];
    
    jupiter.position = CGPointMake(200, 1000);
    [jupiter removeActionForKey:@"BGAnim"];
    
    venus.position = CGPointMake(300, 1300);
    [venus removeActionForKey:@"BGAnim"];
    
    neptune.position = CGPointMake(100, 1600);
    [neptune removeActionForKey:@"BGAnim"];
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
        [self resetBackGround];
        [self moveForrestScene];
    }else if(levelSelected == 2){
        [self resetSpaceBackground];
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
