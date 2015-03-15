//
//  GameScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/2/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()

@end


@implementation GameScene

static NSInteger const kHorizontalShelveGap = 100;
static const uint32_t birdCategory = 1 << 0;
static const uint32_t sidesCategory = 1 << 1;
static const uint32_t floorCategory = 1 << 2;
static const uint32_t shelvesCategory = 1 << 3;
static const uint32_t shelvesFloorCategory = 1 << 4;
static const uint32_t roofCategory = 1 << 5;
static const uint32_t scoreCategory = 1 << 6;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    gameStarted = false;
    goingLeft = false;
    onShelve = false;
    lost = false;
    _touchedTop = false;
    flapCount = 0;
    worldSpeed = 2.5;
    initialDelay = 1.7;
    shelveDelay = 1.6;
    
    //Initializing refrence array
    shelvesReference = [[NSMutableArray alloc] init];
    
    //Change the world gravity
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
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
    [self scoreLabel];
    
}

-(void) scoreLabel{
    // Initialize label and create a label which holds the score
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Bold"];
    _scoreLabelNode.fontColor = [UIColor grayColor];
    _scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 3 * self.frame.size.height / 4 );
    _scoreLabelNode.zPosition = -2;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [self addChild:_scoreLabelNode];
}

-(void) playLevel{
    [self createBird];
    [self populateShelves];
    [self moveScene];
    [self moveBird];
}

-(void) populateShelves{
    [self setShelvesMovement];
    for (int i = 1; i < 7; i++) {
        double shelvePosition = 133.33 * i;
        CGFloat fPosition = (CGFloat) shelvePosition;
        [self spawnShelves:NO yPosition:fPosition];
    }
    SKAction* initShelves = [SKAction performSelector:@selector(initShelves) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:initialDelay];
    [self runAction:[SKAction sequence:@[delay, initShelves]]];
}

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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    // Starts bird movement when game starts
    
    if (_moving.speed > 0) {
        if (!gameStarted) {
            [self playLevel];
            gameStarted = true;
        }else{
            // Tap to jump
            if (flapCount < 2) {
                _bird.physicsBody.velocity = CGVectorMake(0, 0);
                [_bird.physicsBody applyImpulse:CGVectorMake(0, 55)];
                [self runAction:[SKAction playSoundFileNamed:@"flap.mp3" waitForCompletion:NO]];
                flapCount++;
            }
        }
    }else if (lost){ //Lost game
        [self resetScene];
    }
}

-(void) resetScene{
    
    // Moving bird to original position
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 1.7);
    _bird.physicsBody.velocity = CGVectorMake(0, 0);
    _mount1Sprite.position = CGPointMake(CGRectGetMidX(self.frame) * 1.1, (_mount1Sprite.size.height / 2) - 2);
    _mount2Sprite.position = CGPointMake(CGRectGetMidX(self.frame) / 1.3, _mount1Sprite.size.height / 2);
    [_shelves removeAllChildren];
    lost = false;
    _moving.speed = worldSpeed;
    _score = 0;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [shelvesReference removeAllObjects];
    flapCount = 0;
    [player stop];
    [self playMusic:@"BGMusic" withLoop:YES];
    [self populateShelves];
    [self moveBird];
    //[self initShelves]; // Starts generating shells
}

//-----------------------This method genrate random number for left shelve-----------------------------------------
- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}
//______________________________________________________________________________________________________

-(void) createBird{
    //Bird displayed
    SKTexture* ellaTexture1 = [SKTexture textureWithImageNamed:@"ella"];
    _bird = [SKSpriteNode spriteNodeWithTexture:ellaTexture1];
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 1.7);
    _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
    _bird.physicsBody.dynamic = YES;
    _bird.physicsBody.allowsRotation = NO;
    _bird.physicsBody.categoryBitMask = birdCategory;
    _bird.physicsBody.collisionBitMask = sidesCategory | floorCategory | shelvesCategory | shelvesFloorCategory | roofCategory;
    _bird.physicsBody.contactTestBitMask = sidesCategory | floorCategory | shelvesCategory | shelvesFloorCategory | roofCategory;
    [self addChild:_bird];
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

// Moves scene
-(void) moveScene{
    [_mount1Sprite runAction:_moveMount1];
    [_mount2Sprite runAction:_moveMount2];
}

// Creating a ground and sides physics container dummy which will be replaced once shelves are added
-(void) physicsContainer{
    
    _leftSide = [SKNode node];
    _leftSide.position = CGPointMake(self.frame.size.width, 1);
    _leftSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width / 1.72, self.frame.size.height * 2)];
    _leftSide.physicsBody.dynamic = NO;
    _leftSide.physicsBody.categoryBitMask = sidesCategory;
    
    _rightSide = [SKNode node];
    _rightSide.position = CGPointMake(1, 1);
    _rightSide.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width / 1.7, self.frame.size.height * 2)];
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
    CGFloat x = [self randomFloatBetween:-100 and:_sceneSize.bounds.size.width - 150];
    
    SKSpriteNode* leftShelve = [SKSpriteNode spriteNodeWithTexture:_mountShevlesTexture];
    
    if ((int)yPosition < 400 && (int)yPosition > 130) {
        leftShelve.position = CGPointMake(350, 0);
    }else{
        leftShelve.position = CGPointMake(x, 0);
        
        //Adding score node after the solid shelves
        scoreContactNode = [SKNode node];
        //scoreContactNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(kHorizontalShelveGap, leftShelve.size.height)];
        scoreContactNode.position = CGPointMake(x + leftShelve.size.width / 1.78, 40);
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
    
    SKSpriteNode* topOLeftShelve = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(leftShelve.size.width - 2, leftShelve.size.height /4)];
    topOLeftShelve.position = CGPointMake(x, 4.5);
    topOLeftShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topOLeftShelve.size];
    topOLeftShelve.physicsBody.categoryBitMask = shelvesFloorCategory;
    topOLeftShelve.physicsBody.dynamic = NO;
    [shelvePair addChild:topOLeftShelve]; // ** Maybe I need to change this to SKNode
    
    SKSpriteNode* rightShelve = [SKSpriteNode spriteNodeWithTexture:_mountShevlesTexture];
    rightShelve.position = CGPointMake(leftShelve.position.x + leftShelve.size.width + kHorizontalShelveGap, 0);
    rightShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightShelve.size];
    rightShelve.physicsBody.dynamic = NO;
    rightShelve.physicsBody.categoryBitMask = shelvesCategory;
    [shelvePair addChild:rightShelve];
    
    SKSpriteNode* topORightShelve = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(rightShelve.size.width - 2, rightShelve.size.height /4)];
    topORightShelve.position = CGPointMake(x + leftShelve.size.width + kHorizontalShelveGap, 4.5);
    topORightShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topORightShelve.size];
    topORightShelve.physicsBody.categoryBitMask = shelvesFloorCategory;
    topORightShelve.physicsBody.dynamic = NO;
    [shelvePair addChild:topORightShelve];  // ** Maybe I need to change this to SKNode
    
    [shelvesReference addObject:shelvePair];
    
    [shelvePair runAction:_moveAndRemoveShelves];

    [_shelves addChild:shelvePair];  // Addin to stop movement and reset scene;
}
//______________________________________________________________________________________________________

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    if ((contact.bodyA.categoryBitMask & sidesCategory) == sidesCategory || (contact.bodyB.categoryBitMask & sidesCategory) == sidesCategory) { // When bird hits side
        [self moveBird];
    }else if ((contact.bodyA.categoryBitMask & floorCategory) == floorCategory || (contact.bodyB.categoryBitMask & floorCategory) == floorCategory){ // When bird hits floor
            //[self runAction:[SKAction playSoundFileNamed:@"losing.mp3" waitForCompletion:NO]];
        if (onShelve) {
            if (!lost) {
                [player stop];
                [self playMusic:@"losing" withLoop:NO];
                if (_moving.speed > 0) {
                    _moving.speed = 0;
                    [_bird removeActionForKey:@"birdMoving"];
                    [self removeActionForKey:@"spawnThenDelayForever"];
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
        
        int i = 0;
        while (i < shelvesReference.count) {
            SKNode* currentShelve = shelvesReference[i];
            if (currentShelve.position.y < 0) {
                [shelvesReference removeObject:currentShelve];
            }else{
                if (currentShelve.children.count > 4) {
                    if (currentShelve.position.y < _bird.position.y) {
                        _score++;
                        _scoreLabelNode.text = [NSString stringWithFormat:@"%d", _score];
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

//-----------------------Moves bird left to right--------------------------------------------------------
-(void) moveBird{
    //adding motion to the bird
    if (!goingLeft) {
        [_bird removeActionForKey:@"birdMoving"];
        SKAction* birdMoveRight = [SKAction moveByX:_bird.size.width*2 y:0 duration:.004 * _bird.size.width*2];
        SKAction* moveUntilCollision = [SKAction repeatActionForever:birdMoveRight];
        [_bird runAction:moveUntilCollision withKey:@"birdMoving"];
        goingLeft = true;
    }else{
        [_bird removeActionForKey:@"birdMoving"];
        SKAction* birdMoveLeft = [SKAction moveByX:-_bird.size.width * 3 y:0 duration:.004 * _bird.size.width * 3];
        SKAction* moveUntilCollision = [SKAction repeatActionForever:birdMoveLeft];
        [_bird runAction:moveUntilCollision withKey:@"birdMoving"];
        goingLeft = false;
    }
}
//______________________________________________________________________________________________________

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
