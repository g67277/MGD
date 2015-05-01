//
//  ScoreTableViewCell.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/22/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "ScoreTableViewCell.h"

@implementation ScoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMidY(self.frame), self.frame.size.width / 2.5, 50)];
        [self addSubview:usernameLabel];
        
        scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabel.frame.size.width + 10, CGRectGetMidY(self.frame), self.frame.size.width / 2, 50)];
        [self addSubview:scoreLabel];
        
    }
    return self;
}

-(void) refreshCellWithInfor:(NSString*) name score:(int)score{
    
    usernameLabel.text = name;
    usernameLabel.textColor = [UIColor darkGrayColor];
    usernameLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
    
    scoreLabel.text = [NSString stringWithFormat:@"%i", score];
    scoreLabel.textColor = [UIColor darkGrayColor];
    scoreLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
    scoreLabel.textAlignment = NSTextAlignmentRight;
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
