//
//  LocalLeaderBoardViewController.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/22/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreTableViewCell.h"
#import "ScoreData.h"

@interface LocalLeaderBoardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    UIView* header;
    UITableView* myTableView;
    NSMutableArray* incomingScores;
    NSMutableArray* filteredScores;
    NSMutableArray* sortedScores;
    
    NSInteger day;
    NSInteger month;
    
    ScoreData* currentCell;
}

@end
