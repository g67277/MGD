//
//  LocalLeaderBoardViewController.m
//  UpWard
//
//  Created by Nazir Shuqair on 4/22/15.
//  Copyright (c) 2015 Me Time Studios. All rights reserved.
//

#import "LocalLeaderBoardViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#include<unistd.h>
#include<netdb.h>

@interface LocalLeaderBoardViewController ()

@end

@implementation LocalLeaderBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]) {
        incomingScores = [self decodeData:[[[NSUserDefaults standardUserDefaults] arrayForKey:@"scores"] mutableCopy]];
    }
    
    filteredScores = [[NSMutableArray alloc] init];
    sortedScores = [[NSMutableArray alloc] init];
        
    [self filterScores: 1];
    
    [self createUI];
    
    
}

- (NSMutableArray*) decodeData: (NSMutableArray*) encodedArray{
    
    NSMutableArray* decodedObjects = [[NSMutableArray alloc] init];
    ScoreData* scoreData = [[ScoreData alloc] init];
    for (int i = 0; i < encodedArray.count; i++) {
        scoreData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedArray[i]];
        [decodedObjects addObject:scoreData];
    }
    return decodedObjects;
}

- (void) filterScores: (int) filter{
    
    ScoreData* scoreData = [[ScoreData alloc] init];
    NSString* currentDate = [self currentDate];
    if (filter == 0) {
        
        for (scoreData in incomingScores){
            if ([scoreData.date isEqualToString:currentDate]) {
                [filteredScores addObject:scoreData];
            }
        }
    }else if (filter == 1) {
        
        for (scoreData in incomingScores){
            if ([self extractDay:scoreData.date] <= day) {
                [filteredScores addObject:scoreData];
            }
        }
    }else if (filter == 2) {
        
        for (scoreData in incomingScores){
            if ([self extractMonth:scoreData.date] == month) {
                [filteredScores addObject:scoreData];
            }
        }
    }
    
    [self sortData];
}

-(int) extractDay: (NSString*) incomingDate{
    
    NSArray *Array = [incomingDate componentsSeparatedByString:@","];
    int extractedDay = [[Array objectAtIndex:0] intValue];
    
    extractedDay = extractedDay - 7;
    if (extractedDay < 0) {
        extractedDay = 0;
    }
    return extractedDay;
}

-(int) extractMonth: (NSString*) incomingMonth{
    
    NSArray *Array = [incomingMonth componentsSeparatedByString:@","];
    int extractedMonth = [[Array objectAtIndex:1] intValue];
    return extractedMonth;
}

-(NSString*) currentDate{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    day = [components day];
    month = [components month];
    NSInteger year = [components year];
    NSString* currentDate = [NSString stringWithFormat:@"%ld, %ld, %ld", (long)day, (long)month, (long)year];
    
    return currentDate;
}

-(void) sortData{
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    [filteredScores sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    sortedScores = filteredScores;
}

-(void) createUI{
    [self createHeader];
    [self createTableView];
}

-(void) createHeader{
    
    header = [[UIView alloc]init];
    header.backgroundColor = [UIColor whiteColor];
    header.frame = CGRectMake(0, 0, self.view.frame.size.width, 120);
    [self.view addSubview:header];
    
    UIButton* dismissBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dismissBtn addTarget:self
                   action:@selector(onClick:)
         forControlEvents:UIControlEventTouchUpInside];
    [dismissBtn setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismissBtn.frame = CGRectMake(header.frame.size.width - 120, 25, 160.0, 40.0);
    dismissBtn.tag = 1;
    [header addSubview:dismissBtn];
    
    NSArray* filters = [NSArray arrayWithObjects:@"Day", @"Week", @"Month", nil];
    UISegmentedControl* dateFilter = [[UISegmentedControl alloc] initWithItems:filters];
    dateFilter.frame = CGRectMake(0, header.frame.size.height - 30, header.frame.size.width, 30);
    [dateFilter addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    dateFilter.selectedSegmentIndex = 1;
    [header addSubview:dateFilter];
    
    UILabel* filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, header.frame.size.width / 1.5, 30)];
    filterLabel.text = @"Leaderboard";
    filterLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:25];
    [header addSubview:filterLabel];
}

-(void) createTableView{
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, header.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - header.frame.size.height) style:UITableViewStylePlain];
    
    myTableView.rowHeight = 75;
    myTableView.scrollEnabled = YES;
    myTableView.userInteractionEnabled = YES;
    myTableView.bounces = YES;
    
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[ScoreTableViewCell class] forCellReuseIdentifier:@"scoreCell"];
    [self.view addSubview:myTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [sortedScores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scoreCell"];
    currentCell = [sortedScores objectAtIndex:indexPath.row];
    [cell refreshCellWithInfor:currentCell.username score:currentCell.score];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isNetworkAvailable]) {
        [self facebookRefresh:(int)indexPath.row];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Offline" message:@"Please make sure you are connected to share you score" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) facebookRefresh: (int) index{
    
    ScoreData* scoreData = [[ScoreData alloc] init];
    scoreData = sortedScores[index];
    
    SLComposeViewController* slComposeViewController;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [slComposeViewController setInitialText:[NSString stringWithFormat:@"Check out my score for Fluffy Escape! \n%@s score: %i", scoreData.username, scoreData.score]];
        [slComposeViewController addImage:[UIImage imageNamed:@"ella"]];
        [self presentViewController:slComposeViewController animated:NO completion:NULL];
    }else{
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts on this device.  Please add an account in settings and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}


-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
}

-(void)onClick:(UIButton*) sender{
    
    if (sender.tag == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void) segmentedControlAction:(UISegmentedControl *)segment{
    
    [filteredScores removeAllObjects];
    [sortedScores removeAllObjects];
    
    if (segment.selectedSegmentIndex == 0) {
        [self filterScores:0];
    }else if (segment.selectedSegmentIndex == 1){
        [self filterScores:1];
    }else if (segment.selectedSegmentIndex == 2){
        [self filterScores:2];
    }
    
    [myTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
