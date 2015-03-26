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
    SKSpriteNode* _mount1Sprite;
    SKSpriteNode* _mount2Sprite;
    SKColor* _background;
    SKTexture* _mountShevlesTexture;
    
    //Intro items
    SKSpriteNode* titleBanner;
    SKSpriteNode* playBtn;
    SKAction* _titleMove;
    SKAction* _playBtnMove;
    
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
    SKAction* _moveMount1;
    SKAction* _moveMount2;
    SKAction* _fly;
    SKAction* _cry;
    SKAction* _fight;
    SKAction* _flapSound;
    SKAction* moveUntilCollisionR;
    SKAction* moveUntilCollisionL;
    SKAction* moveCatRight;
    SKAction* scaleScoreBG;
    SKAction* losingScoreAnimation;
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
    
    //Score label and counting integer
    SKLabelNode* _scoreLabelNode;
    SKLabelNode* _highScoreLabelNode;
    NSInteger _score;
    SKLabelNode* gameOver; // Need to change;
    
    NSInteger kHorizontalShelveGap;
    
    int flapCount;
    BOOL _canRestart;
    BOOL _touchedTop;
    
    float worldSpeed;
    float initialDelay;
    float shelveDelay;
    
    //testing... to be deleted
    Boolean onShelve;
    Boolean lost;
    Boolean goingLeft;
    AVAudioPlayer* player;
}

@end
