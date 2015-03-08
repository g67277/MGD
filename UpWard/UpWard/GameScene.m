//
//  GameScene.m
//  UpWard
//
//  Created by Nazir Shuqair on 3/2/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "GameScene.h"

@interface GameScene() <SKPhysicsContactDelegate>{
    SKSpriteNode* _bird;
    SKColor* _background;
    SKTexture* _mountShevlesTexture;
    SKAction* _moveAndRemoveShelves;
    SKView* _sceneSize;
    SKNode* _dummyFloor;
    SKNode* _leftSide;
    SKNode* _rightSide;
    
    int flapCount;
    
    //testing... to be deleted
    Boolean onShelve;
    Boolean lost;
}


@end


@implementation GameScene

static NSInteger const kHorizontalShelveGap = 100;
static const uint32_t birdCategory = 1 << 0;
static const uint32_t sidesCategory = 1 << 1;
static const uint32_t floorCategory = 1 << 2;
static const uint32_t shelvesCategory = 1 << 3;


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    gameStarted = false;
    goingLeft = false;
    onShelve = false;
    lost = false;
    flapCount = 0;
    
    //Set up background music--------------------------------------
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"BGMusic"
                                         ofType:@"mp3"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops = -1;
    player.volume = .3;
    [player play];
    
    //Change the world gravity
    self.physicsWorld.gravity = CGVectorMake( 0.0, -4.0 );
    self.physicsWorld.contactDelegate = self;
    _sceneSize = (SKView *)self.view;
    
    //Adding the container
    [self physicsContainer];
    
    //Background for the level
    _background = [SKColor colorWithRed:113.0/225.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    self.backgroundColor = _background;
    
    [self createBird];
    [self createScene];
    [self initShelves];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    // Starts bird movement when game starts
    if (!gameStarted) {
        [self moveBird];
        gameStarted = true;
    }else{
        // Tap to jump
        if (flapCount > 1) {
            flapCount = 0;
        }else{
            _bird.physicsBody.velocity = CGVectorMake(0, 0);
            [_bird.physicsBody applyImpulse:CGVectorMake(0, 55)];
            [self runAction:[SKAction playSoundFileNamed:@"flap.mp3" waitForCompletion:NO]];
            flapCount++;
        }
    }
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
    _bird.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 4);
    _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
    _bird.physicsBody.dynamic = YES;
    _bird.physicsBody.allowsRotation = NO;
    _bird.physicsBody.categoryBitMask = birdCategory;
    _bird.physicsBody.collisionBitMask = sidesCategory | floorCategory | shelvesCategory;
    _bird.physicsBody.contactTestBitMask = sidesCategory | floorCategory | shelvesCategory;
    [self addChild:_bird];
}

-(void) createScene{
    //Parallax background
    //MainMountain
    SKTexture* mainMountainTexture = [SKTexture textureWithImageNamed:@"mainMountain"];
    SKAction* moveMount1 = [SKAction moveByX:0 y:-mainMountainTexture.size.height*2 duration:0.1 * mainMountainTexture.size.height*2];
    SKSpriteNode* mount1Sprite = [SKSpriteNode spriteNodeWithTexture:mainMountainTexture];
    mount1Sprite.zPosition = -10;
    mount1Sprite.position = CGPointMake(CGRectGetMidX(self.frame) * 1.1, (mount1Sprite.size.height / 2) - 2);
    [mount1Sprite runAction:moveMount1];
    [self addChild:mount1Sprite];
    
    //Second Mountain
    SKTexture* secondMountainTexture = [SKTexture textureWithImageNamed:@"secondMountain"];
    SKAction* moveMount2 = [SKAction moveByX:0 y:-secondMountainTexture.size.height*2 duration:0.15 * secondMountainTexture.size.height*2];
    SKSpriteNode* mount2Sprite = [SKSpriteNode spriteNodeWithTexture:secondMountainTexture];
    mount2Sprite.zPosition = -15;
    mount2Sprite.position = CGPointMake(CGRectGetMidX(self.frame) / 1.3, mount1Sprite.size.height / 2);
    [mount2Sprite runAction:moveMount2];
    [self addChild:mount2Sprite];
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
    
    [self addChild:_leftSide];
    [self addChild:_rightSide];
    [self addChild:_dummyFloor];
}
//______________________________________________________________________________________________________

-(void) initShelves{
    //Creating the shelves here
    _mountShevlesTexture = [SKTexture textureWithImageNamed:@"mountShelve"];
    
    CGFloat distanceToMove = self.frame.size.height + 2 * _mountShevlesTexture.size.height;
    SKAction* moveShelves = [SKAction moveByX:0 y:-distanceToMove duration:0.03 * distanceToMove];
    SKAction* removeShelves = [SKAction removeFromParent];
    _moveAndRemoveShelves = [SKAction sequence:@[moveShelves, removeShelves]];
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnShelves) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:4.0];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}

//-----------------------This method spawn shelves regularly-----------------------------------------
-(void) spawnShelves{
    SKNode* shelvePair = [SKNode node];
    shelvePair.position = CGPointMake(0, self.frame.size.height + _mountShevlesTexture.size.height * 2);
    shelvePair.zPosition = -5;
    
    //Random number for the left shelve
    CGFloat x = [self randomFloatBetween:-100 and:_sceneSize.bounds.size.width - 150];
    
    SKSpriteNode* leftShelve = [SKSpriteNode spriteNodeWithTexture:_mountShevlesTexture];
    leftShelve.position = CGPointMake(x, 0);
    leftShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftShelve.size];
    leftShelve.physicsBody.dynamic = NO;
    leftShelve.physicsBody.categoryBitMask = shelvesCategory;
    [shelvePair addChild:leftShelve];
    
    SKSpriteNode* rightShelve = [SKSpriteNode spriteNodeWithTexture:_mountShevlesTexture];
    rightShelve.position = CGPointMake(x + leftShelve.size.width + kHorizontalShelveGap, 0);
    rightShelve.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightShelve.size];
    rightShelve.physicsBody.dynamic = NO;
    rightShelve.physicsBody.categoryBitMask = shelvesCategory;
    [shelvePair addChild:rightShelve];
    
    [shelvePair runAction:_moveAndRemoveShelves];
    [self addChild:shelvePair];
}
//______________________________________________________________________________________________________

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    if ((contact.bodyA.categoryBitMask & sidesCategory) == sidesCategory || (contact.bodyB.categoryBitMask & sidesCategory) == sidesCategory) {
        [self moveBird];
    }else if ((contact.bodyA.categoryBitMask & floorCategory) == floorCategory || (contact.bodyB.categoryBitMask & floorCategory) == floorCategory){
            //[self runAction:[SKAction playSoundFileNamed:@"losing.mp3" waitForCompletion:NO]];
        if (onShelve) {
            if (!lost) {
                [player stop];
                [self runAction:[SKAction playSoundFileNamed:@"losing.mp3" waitForCompletion:NO]];
                onShelve = false;
                lost = true;
            }
        }
    }else if((contact.bodyA.categoryBitMask & shelvesCategory) == shelvesCategory || (contact.bodyB.categoryBitMask & shelvesCategory) == shelvesCategory){
        onShelve = true;
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
