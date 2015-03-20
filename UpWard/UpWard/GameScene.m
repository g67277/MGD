//
//  GameScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/2/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "GameScene.h"
#import "Sprites.h"
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface GameScene()

@end


@implementation GameScene

static const uint32_t birdCategory = 1 << 0;
static const uint32_t sidesCategory = 1 << 1;
static const uint32_t floorCategory = 1 << 2;
static const uint32_t shelvesCategory = 1 << 3;
static const uint32_t shelvesFloorCategory = 1 << 4;
static const uint32_t roofCategory = 1 << 5;
static const uint32_t scoreCategory = 1 << 6;

NSString *const BodyRightWall = @"bodyRightWall";
NSString *const BodyLeftWall = @"bodyLeftWall";
NSString *const SolidShelvePosition = @"solidShelvePosition";
NSString *const HorizontalShelveGap = @"HorizontalShelveGap";


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    //Game Setup
    gameStarted = false;
    goingLeft = false;
    onShelve = false;
    lost = false;
    _touchedTop = false;
    flapCount = 0;
    worldSpeed = 3.5;
    initialDelay = 1.7;
    shelveDelay = 1.5;
    kHorizontalShelveGap = [self deviceSize:HorizontalShelveGap];

    //Initializing refrence array
    shelvesReference = [[NSMutableArray alloc] init];
    
    //Change the world gravity
    self.physicsWorld.gravity = CGVectorMake( 0.0, -6.0 );
    self.physicsWorld.contactDelegate = self;
    _sceneSize = (SKView *)self.view;
    
    //Background for the level
        _background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    self.backgroundColor = _background;
    
    //Creating the shelves texture here
    _mountShevlesTexture = [SKTexture textureWithImageNamed:@"mountShelve"];
    
    _moving = [SKNode node];
    [self addChild:_moving];
    
    //Speed of the game
    _moving.speed = worldSpeed;
    
    _shelves = [SKNode node];
    [_moving addChild:_shelves];
    
    [self playMusic:@"BGMusic" withLoop:YES];
    //Adding the container
    [self physicsContainer];
    [self createScene];
    //Adding header
    [self addHeader];
    
    
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

-(void) createBird{
    //Bird displayed
    //SKTexture* ellaTexture1 = [SKTexture textureWithImageNamed:@"ella_spriteSheet1"];
    _bird = [SKSpriteNode spriteNodeWithTexture:SPRITES_TEX_ELLA_FLAPDOWN];
    [_bird setScale:1.3];
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 1.7);
    _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
    _bird.physicsBody.dynamic = YES;
    _bird.physicsBody.allowsRotation = NO;
    _bird.physicsBody.categoryBitMask = birdCategory;
    _bird.physicsBody.collisionBitMask = sidesCategory | floorCategory | shelvesCategory | shelvesFloorCategory | roofCategory;
    _bird.physicsBody.contactTestBitMask = sidesCategory | floorCategory | shelvesCategory | shelvesFloorCategory | roofCategory;
    [self addChild:_bird];
    
    // Might need to move somewhere else
    SKAction* flap = [SKAction animateWithTextures:SPRITES_ANIM_ELLA_FLAP timePerFrame:.1];
    SKAction* tears = [SKAction animateWithTextures:SPRITES_ANIM_ELLA_TEAR timePerFrame:.75];
    _fly = [SKAction repeatAction:flap count:3];
    _cry = [SKAction repeatActionForever:tears];
}

-(void) createScene{
    //Parallax background
    //MainMountain
    SKTexture* mainMountainTexture = [SKTexture textureWithImageNamed:@"mainMountain"];
    _moveMount1 = [SKAction moveByX:0 y:-mainMountainTexture.size.height*2 duration:0.1 * mainMountainTexture.size.height*2];
    _mount1Sprite = [SKSpriteNode spriteNodeWithTexture:mainMountainTexture];
    _mount1Sprite.zPosition = -10;
    _mount1Sprite.position = CGPointMake(CGRectGetMidX(self.frame) * 1.1, (_mount1Sprite.size.height / 2) - 2);
    [_moving addChild:_mount1Sprite]; // adding it to stop movement
    
    //Second Mountain
    SKTexture* secondMountainTexture = [SKTexture textureWithImageNamed:@"secondMountain"];
    _moveMount2 = [SKAction moveByX:0 y:-secondMountainTexture.size.height*2 duration:0.15 * secondMountainTexture.size.height*2];
    _mount2Sprite = [SKSpriteNode spriteNodeWithTexture:secondMountainTexture];
    _mount2Sprite.zPosition = -15;
    _mount2Sprite.position = CGPointMake(CGRectGetMidX(self.frame) / 1.3, _mount1Sprite.size.height / 2);
    [_moving addChild:_mount2Sprite]; // adding to stop movement
}

-(void) playLevel{
    [self createBird];
    [self populateShelves];
    [self moveScene];
    [self scoreLabel];
    [self initAllActions];
    [self moveBird];
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
    
    // Scale losing background, change font size and color
    scaleScoreBG = [SKAction scaleTo:1.8 duration:.1];
    losingScoreAnimation = [SKAction runBlock:(dispatch_block_t)^(){
        scoreBG.zPosition = 10;
        scoreBG.fillColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _scoreLabelNode.fontSize = 100;
        _scoreLabelNode.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) - 100);
        _scoreLabelNode.zPosition = 11;
        _scoreLabelNode.fontColor = [UIColor grayColor];
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
    
    shelvePair = [SKNode node];
    if (!started) { // Create the scene by adding shelves manually
        shelvePair.position = CGPointMake(0, yPosition);
    }else{ // once the scene is created, create shelves automotically
        shelvePair.position = CGPointMake(0, self.frame.size.height + _mountShevlesTexture.size.height * 2);
    }
    shelvePair.zPosition = -5;
    
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
        //scoreContactNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(kHorizontalShelveGap + 10, leftShelve.size.height)];
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
-(void) moveScene{
    [_mount1Sprite runAction:_moveMount1 withKey:@"moveScene"];
    [_mount2Sprite runAction:_moveMount2 withKey:@"moveScene"];
}

//-----------------------Moves bird left to right--------------------------------------------------------
-(void) moveBird{
    //adding motion to the bird
    if (!goingLeft) {
        _bird.texture = SPRITES_TEX_ELLA_LOOKLEFT;
        [_bird removeActionForKey:@"birdMoving"];
        [_bird runAction:moveUntilCollisionR withKey:@"birdMoving"];
        goingLeft = true;
    }else{
        _bird.texture = SPRITES_TEX_ELLA_LOOKRIGHT;
        [_bird removeActionForKey:@"birdMoving"];
        [_bird runAction:moveUntilCollisionL withKey:@"birdMoving"];
        goingLeft = false;
    }
}
//______________________________________________________________________________________________________

#pragma HUD Methods

- (void) addHeader{
    
    SKSpriteNode* headerNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:81.0/255.0f green:68.0/255.0f blue:66.0/255.0f alpha:1.0] size:CGSizeMake(self.frame.size.width * 2, 100)];
    //SKSpriteNode* headerNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.frame.size.width * 2, 65)];
    headerNode.position = CGPointMake(1, self.frame.size.height / 1.04);
    headerNode.zPosition = 0;
    headerNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 80)];
    headerNode.physicsBody.dynamic = NO;
    headerNode.physicsBody.categoryBitMask = roofCategory;
    [self addChild:headerNode];
    
    SKSpriteNode* bigCoin = [SKSpriteNode spriteNodeWithImageNamed:@"coin_big"];
    [bigCoin setScale:1.5];
    bigCoin.position = CGPointMake([self deviceSize:BodyRightWall] + bigCoin.size.width / 2, self.frame.size.height / 1.04);
    bigCoin.zPosition = 20;
    
    [self addChild:bigCoin];
    [self addChild:[self pauseBtnNode]];
}

- (SKSpriteNode *)pauseBtnNode{
    SKSpriteNode* pauseNode = [SKSpriteNode spriteNodeWithImageNamed:@"pauseBtn"];
    [pauseNode setScale:1.35];
    pauseNode.position = CGPointMake(CGRectGetMidX( self.frame ), self.frame.size.height / 1.045 );
    pauseNode.name = @"pauseBtn";//how the node is identified later
    pauseNode.zPosition = 10.0;
    
    return pauseNode;
}

-(void) scoreLabel{
    
    scoreBG = [SKShapeNode shapeNodeWithCircleOfRadius:150];
    scoreBG.fillColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    scoreBG.position = CGPointMake( CGRectGetMidX( self.frame ), CGRectGetMidY(self.frame));
    scoreBG.zPosition = -8;
    
    // Initialize label and create a label which holds the score
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    _scoreLabelNode.fontColor = [UIColor lightGrayColor];
    _scoreLabelNode.fontSize = 120;
    _scoreLabelNode.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) - 35);
    _scoreLabelNode.zPosition = -7;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [self addChild:_scoreLabelNode];
    [self addChild:scoreBG];

}

-(void) losingLabel{
    
    gameOver = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    gameOver.fontColor = [UIColor grayColor];
    gameOver.fontSize = 85;
    gameOver.position = CGPointMake(CGRectGetMidX(scoreBG.frame), CGRectGetMidY(scoreBG.frame) + 30);
    gameOver.zPosition = 11;
    gameOver.text = @"Game Over!";
    [self addChild:gameOver];
    
    [scoreBG runAction:scaleScoreBG];
    _scoreLabelNode.text = [NSString stringWithFormat:@"Score: %ld", (long)_score];
    [scoreBG runAction:losingScoreAnimation];

}

-(void) pauseGame{
    if(!_sceneSize.paused){
        _sceneSize.paused = YES;
        [player pause];
    }else{
        _sceneSize.paused = NO;
        [player play];
    }
}


#pragma Touch and Collision detection

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];
    
        // Starts bird movement when game starts
        
        if (_moving.speed > 0) {
            if ([node.name isEqualToString:@"pauseBtn"]) {
                [self pauseGame];
            }else{
                if (!gameStarted) {
                    [self playLevel];
                    gameStarted = true;
                }else{
                    // Tap to jump
                    if (flapCount < 2) {
                        _bird.physicsBody.velocity = CGVectorMake(0, 0);
                        [_bird.physicsBody applyImpulse:CGVectorMake(0, 120)];
                        [self runAction:_flapSound];
                        [_bird runAction:_fly];
                        flapCount++;
                    }
                }
            }
        }else if (lost){ //Lost game
            [self resetScene];
        }
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    if ((contact.bodyA.categoryBitMask & sidesCategory) == sidesCategory || (contact.bodyB.categoryBitMask & sidesCategory) == sidesCategory) { // When bird hits side
        [self moveBird];
    }else if ((contact.bodyA.categoryBitMask & floorCategory) == floorCategory || (contact.bodyB.categoryBitMask & floorCategory) == floorCategory){ // When bird hits floor
        if (onShelve) {
            if (!lost) {
                [player stop];
                [self playMusic:@"losing" withLoop:NO];
                if (_moving.speed > 0) {
                    _moving.speed = 0;
                    [_bird removeActionForKey:@"birdMoving"];
                    [self removeActionForKey:@"spawnThenDelayForever"];
                    [self losingLabel];
                }
                onShelve = false;
                lost = true;
            }
        }
    }else if((contact.bodyA.categoryBitMask & shelvesCategory) == shelvesCategory || (contact.bodyB.categoryBitMask & shelvesCategory) == shelvesCategory){ // When bird hits shelves
        onShelve = true; //Needs to be changed****
    }else if ((contact.bodyA.categoryBitMask & shelvesFloorCategory) == shelvesFloorCategory || (contact.bodyB.categoryBitMask & shelvesFloorCategory) == shelvesFloorCategory){ // when bird hits top of shelve
        flapCount = 0; // resets the flap count only when the floor is touched so that the bird can only jump twice
    }else if ((contact.bodyA.categoryBitMask & roofCategory) == roofCategory || (contact.bodyB.categoryBitMask & roofCategory) == roofCategory){
        
        //Increase dificulty when the roof is touched
        //Work in progress......
        /*
         if (_touchedTop) {
         _touchedTop = false;
         worldSpeed = worldSpeed + 0.1;
         _moving.speed = worldSpeed;
         shelveDelay = shelveDelay - 0.15;
         [self removeActionForKey:@"spawnThenDelayForever"];
         SKAction* initShelves = [SKAction performSelector:@selector(initShelves) onTarget:self];
         SKAction* delay = [SKAction waitForDuration:shelveDelay - 0.5];
         [self runAction:[SKAction sequence:@[delay, initShelves]]];
         }else{
         _touchedTop = true;
         }
         */
        
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
                        _score++;
                        _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
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
    }
}

#pragma Reset Scene

-(void) resetScene{
    
    // Moving bird to original position
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 1.7);
    _bird.physicsBody.velocity = CGVectorMake(0, 0);
    
    // Reseting the scene
    [_mount1Sprite removeActionForKey:@"moveScene"];
    [_mount2Sprite removeActionForKey:@"moveScene"];
    _mount1Sprite.position = CGPointMake(CGRectGetMidX(self.frame) * 1.1, (_mount1Sprite.size.height / 2) - 2);
    _mount2Sprite.position = CGPointMake(CGRectGetMidX(self.frame) / 1.3, _mount1Sprite.size.height / 2);
    [self moveScene];
    
    // Removing all shelves to repopulate screen
    // Clearing all refrences
    [_shelves removeAllChildren];
    [shelvesReference removeAllObjects];

    // remove crying animations
    [_bird removeActionForKey:@"crying"];
    
    // Reset game status
    lost = false;
    
    // Moving the world again
    _moving.speed = worldSpeed;
    
    // remove lose label and recreating score label
    [_scoreLabelNode removeFromParent];
    [scoreBG removeFromParent];
    [gameOver removeFromParent];
    [self scoreLabel];

    flapCount = 0; // This needs to be changed**
    
    // Stop losing music to play the game background music
    [player stop];
    [self playMusic:@"BGMusic" withLoop:YES];
    
    // Recreate shelves
    [self populateShelves];
    
    // Start bird movement
    [self moveBird];
    
    // Reset bird texture
    _bird.texture = SPRITES_TEX_ELLA_FLAPDOWN;
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Start crying animation when close to losing
    
    if (_bird.position.y < 250) {
        [_bird runAction:_cry withKey:@"crying"];
    }else{
        [_bird removeActionForKey:@"crying"];
    }
}

@end
