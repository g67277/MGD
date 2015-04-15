//
//  GameScene.h
//  UpWard
//

//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>{
    
    SKSpriteNode* _bird;
    SKSpriteNode* _cat;
    SKColor* _background;
    SKTexture* _mountShevlesTexture;
    
    //Intro items
    SKSpriteNode* titleBanner;
    SKSpriteNode* playBtn;
    SKAction* _titleMove;
    SKAction* _playBtnMove;
    SKSpriteNode* pauseNode;
    
    //Scene SkSpriteNodes
    SKSpriteNode* grass;
    SKSpriteNode* frontTree;
    SKSpriteNode* rightTree;
    SKSpriteNode* leftTree;
    SKSpriteNode* rightMidTree;
    SKSpriteNode* leftMidTree;
    SKSpriteNode* midTree;
    SKSpriteNode* bGTrees;
    SKSpriteNode* lake;
    SKSpriteNode* smallMount1;
    SKSpriteNode* smallMount2;
    SKSpriteNode* smallMount3;
    SKSpriteNode* largeMount1;
    SKSpriteNode* largeMount2;
    
    //Scene Animation
    SKAction* keepGM;
    SKAction* keepFTM;
    SKAction* keepLTM;
    SKAction* keepRTM;
    SKAction* keepRMTM;
    SKAction* keepLMTM;
    SKAction* keepMTM;
    SKAction* keepBGTL;
    SKAction* keepSM1;
    SKAction* keepSM2;
    SKAction* keepSM3;
    SKAction* keepLM1;
    SKAction* keepLM2;

    SKAction* _moveAndRemoveShelves;
    SKAction* _fly;
    SKAction* _cry;
    SKAction* _fight;
    SKAction* _flapSound;
    SKAction* moveUntilCollisionR;
    SKAction* moveUntilCollisionL;
    SKAction* moveCatRight;
    SKAction* scaleScoreBG;
    SKAction* losingScoreAnimation;
    SKLabelNode* coinsCollectedLabel;
    SKAction* bounceScoreLabel;
    SKAction* bounceScoreBG;
    SKView* _sceneSize;
    SKNode* _dummyFloor;
    SKNode* _dummyRoof;
    SKNode* _leftSide;
    SKNode* _rightSide;
    SKNode* shelvePair;
    SKNode* _shelves;
    SKNode* _moving;
    // Score node
    SKNode* scoreContactNode;
    SKShapeNode* scoreBG;
    // Array to keep a reference to all the shelves
    NSMutableArray* shelvesReference;
    NSMutableArray* coinsReference;
    
    //Score label and counting integer
    SKLabelNode* _scoreLabelNode;
    SKLabelNode* _highScoreLabelNode;
    NSInteger _score;
    SKLabelNode* gameOver;
    SKLabelNode* restartLabel;
    
    NSInteger kHorizontalShelveGap;
    
    int flapCount;
    int shelveCount;
    float worldSpeed;
    float initialDelay;
    float shelveDelay;
    
    Boolean lost;
    Boolean goingLeft;
    AVAudioPlayer* player;
    
    //Testing:
    
    SKTexture* birdTexture;
    SKTexture* birdLeft;
    SKTexture* birdRight;
    SKTexture* birdCrying;
    NSArray* birdFight;
}

@end
