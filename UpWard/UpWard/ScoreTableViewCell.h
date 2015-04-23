//
//  ScoreTableViewCell.h
//  UpWard
//
//  Created by Nazir Shuqair on 4/22/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreTableViewCell : UITableViewCell{
    
    UILabel* usernameLabel;
    UILabel* scoreLabel;
}

-(void) refreshCellWithInfor:(NSString*) name score:(int)score;

@end
