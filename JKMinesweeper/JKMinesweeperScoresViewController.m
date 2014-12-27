//
//  JKMinesweeperScoresViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKMinesweeperScoresViewController.h"
#import "JKScoresCustomTableViewCell.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "ScoreSaver.h"
#import "JKMineSweeperConstants.h"
#import "UIView+Utility.h"
#import "Score.h"

#define cellIdentifier @"JKScoresCustomTableViewCell"

@interface JKMinesweeperScoresViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RLMResults* scoreObjectsCollection;
@property (strong, nonatomic) NSArray* levelSequenceToNameMappings;
@end

@implementation JKMinesweeperScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.levelSequenceToNameMappings = @[@"", @"Easy", @"Medium", @"Difficult", @"Expert"];
    [self.tableView addBorderWithColor:[UIColor blackColor] andWidth:1.0f];
    [self addFooterView];
}

-(void)viewWillAppear:(BOOL)animated {
    self.scoreObjectsCollection = [ScoreSaver getAllScoresFromDatabase];
    [self.tableView reloadData];
}

#pragma MARK tableView dataSource and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scoreObjectsCollection.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath  *)indexPath {
    JKScoresCustomTableViewCell* currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Score* currentScoreObject = self.scoreObjectsCollection[indexPath.row];
    
    if(currentCell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"JKScoresCustomTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    currentCell.sequence.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
    currentCell.playerName.text = currentScoreObject.userName;
    currentCell.score.text = [NSString stringWithFormat:@"%ld",(long)currentScoreObject.scrore];
    currentCell.gameLevel.text = self.levelSequenceToNameMappings[currentScoreObject.gameLevel];
    return currentCell;
}

- (IBAction)clearAllScoresButtonPressed:(UIButton*)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Scores History" message:@"Are you sure you want to clear all the previous scores?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1) {
            NSLog(@"Deleting all recrods");
        }
    }];
}

-(void)addFooterView {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    [footerView setBackgroundColor:[UIColor lightGrayColor]];
    self.tableView.tableFooterView = footerView;
}

- (IBAction)dismissCurrentViewPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_POPOVER_VIEW_NOTIFICATION object:nil];
}



@end
