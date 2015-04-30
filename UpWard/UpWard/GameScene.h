//
//  GameScene.h
//  UpWard
//

//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ScoreData.h"
#import "GameViewController.h"
#import "SpaceScene.h"
#import "ForrestScene.h"

//Legend
// * : need to relook and update
// # : good to go


@interface GameScene : SKScene <SKPhysicsContactDelegate>{
    
    //Bird items
    SKSpriteNode* _bird; //Bird Node*
    SKAction* _fly; // Fly action*
    SKAction* _cry; // Cry Action*
    SKAction* _fight; // Fight Action*
    SKAction* _flapSound; // Flap sound*
    SKAction* moveUntilCollisionR; // movement actions, can be updated#
    SKAction* moveUntilCollisionL; // movement actions, can be updated#
    int flapCount; // Counts the jumps, resets after 2#
    SKTexture* birdTexture; // Regular bird texture#
    SKTexture* birdLeft; // Bird looking left texture#
    SKTexture* birdRight; // Bird looking right texture#
    SKTexture* birdCrying; // Bird crying texture#
    NSArray* birdFight; // Bird fighting texture array#
    
    
    
    //Cat items
    SKSpriteNode* _cat; // Cat Node*
    
    
    
    // background items
    SKColor* _background; // Background, need to change location*
    
    
    
    //shelves items
    SKTexture* _shevlesTexture; // Shelve texture, need to change location*
    SKAction* _moveAndRemoveShelves; // good to go#
    SKNode* _shelves; // used to hold shelve pairs, good to go#
    NSMutableArray* shelvesReference; //Holds a reference to all shelves, for score#
    NSInteger kHorizontalShelveGap; // Gap between shelves, constant#
    int shelveCount; // Counts the shelves displayed, used for reference#
    int shelveCountChicks; // Used to display chicks every x shelves#
    
    
    
    //Intro items
    SKSpriteNode* titleBanner; // Need to change location*
    SKSpriteNode* playBtn; // need to rename and change location*
    SKAction* _titleMove; // need to change location*
    SKAction* _playBtnMove; // need to rename and change location*
    
    
    
    //Header items
    SKSpriteNode* pauseNode; // Need to update...*
    SKLabelNode* coinsCollectedLabel; // Coins label#
    SKLabelNode* chicksCollectedLabel; // Chicks Label#
    
    
    
    //Score items
    SKShapeNode* scoreBG; // Background circle for score*
    SKAction* scaleScoreBG; // Expands score background*
    SKAction* losingScoreAnimation; // Expands score bubble*
    SKAction* bounceScoreLabel; // Scales score when a score increases#
    SKAction* bounceScoreBG; // Scales score when a score increases#
    NSMutableArray* coinsReference; // holds coins nods for reference#
    NSMutableArray* chicksReference; // holds chicks nods for refernce#
    SKLabelNode* _scoreLabelNode; // Score label#
    SKLabelNode* _highScoreLabelNode; // Highscore label#
    NSInteger _score; // temporary, will change*
    SKLabelNode* gameOver; // Game over label#
    SKLabelNode* restartLabel; // Restart label#
    
    
    
    SKView* _sceneSize; // used for pausing game, need to change*
    SKNode* _dummyFloor; // need to include in did contact to lose if bird touches ground*
    SKNode* _moving; // Parent node, good to go#
    // Score node
    
    
    
    float worldSpeed; // constant, can be used to update the speed of the game#
    float initialDelay; // constant, used to delay daynamic shelves until static one have been moved#
    float shelveDelay; // constant, delay between each shelve#
    
    
    
    Boolean lost; // Checks if the game has been lost#
    Boolean goingLeft; // calculates the bird movement*
    int levelSelected; // checks which level to display*
    AVAudioPlayer* player; // player object to play sound*
    NSString* username; //holds the username*
    
    
    
    //Saving scores
    NSMutableArray* scoresArray; //*
    NSMutableArray* incomingScoresArray; //*
    NSMutableArray* highScoreArray; //*
    NSMutableArray* incomingHighScoreArray; //*
    
    
    
    //------------------Levels---------------------
    SpaceScene* spaceLevel;
    SKNode* spaceScene;
    ForrestScene* forrestLevel;
    SKNode* forrestScene;
    
    //-----------------------------------------

}



@end
