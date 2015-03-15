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
    SKSpriteNode* _mount1Sprite;
    SKSpriteNode* _mount2Sprite;
    SKColor* _background;
    SKTexture* _mountShevlesTexture;
    SKAction* _moveAndRemoveShelves;
    SKAction* _moveMount1;
    SKAction* _moveMount2;
    SKAction* _fly;
    SKAction* _cry;
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
    NSInteger _score;
    
    
    int flapCount;
    BOOL _canRestart;
    BOOL _touchedTop;
    
    float worldSpeed;
    float initialDelay;
    float shelveDelay;
    
    //testing... to be deleted
    Boolean onShelve;
    Boolean lost;
    Boolean gameStarted;
    Boolean goingLeft;
    AVAudioPlayer* player;
}

@end
