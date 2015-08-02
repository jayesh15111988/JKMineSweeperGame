//
//  JKMinesweeperSavedGamesViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKMinesweeperSavedGamesViewController.h"
#import "UIView+Utility.h"
#import "SavedGameOperation.h"
#import "JKScoresCustomTableViewCell.h"
#import "JKMineSweeperConstants.h"
#import "SaveGameModel.h"

#import <UIAlertView+BlocksKit.h>
#import <RLMResults.h>

@interface JKMinesweeperSavedGamesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* levelSequenceToNameMappings;
@property (strong, nonatomic) RLMResults* savedGamesCollection;
@property (weak, nonatomic) IBOutlet UIButton *clearSavedGamesButton;
@end

@implementation JKMinesweeperSavedGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.levelSequenceToNameMappings = @[@"", @"Easy", @"Medium", @"Difficult", @"Expert"];
    [self.tableView addBorderWithColor:[UIColor blackColor] andWidth:1.0f];
    [self addFooterView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSavedGames];
}

-(void)loadSavedGames {
    self.savedGamesCollection =[SaveGameModel allObjects];
    self.clearSavedGamesButton.hidden = (self.savedGamesCollection.count == 0);
    [self.tableView reloadData];
}

-(void)addFooterView {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    [footerView setBackgroundColor:[UIColor lightGrayColor]];
    self.tableView.tableFooterView = footerView;
}

#pragma MARK tableView dataSource and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.savedGamesCollection.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath  *)indexPath {
    JKScoresCustomTableViewCell* currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    SaveGameModel* currentGameObject = self.savedGamesCollection[indexPath.row];
    
    if (currentCell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"JKScoresCustomTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        currentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    currentCell.sequence.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
    currentCell.playerName.text = currentGameObject.savedGameName;
    currentCell.score.text = [NSString stringWithFormat:@"%ld",(long)currentGameObject.score];
    currentCell.gameLevel.text = self.levelSequenceToNameMappings[currentGameObject.levelNumber];
    return currentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SaveGameModel* selectedSavedGame = self.savedGamesCollection[indexPath.row];
    if (self.openSelectedGameModel) {
        self.openSelectedGameModel(selectedSavedGame);
    }
}

- (IBAction)dismissCurrentViewPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_POPOVER_VIEW_NOTIFICATION object:nil];
}

- (IBAction)clearAllScoresButtonPressed:(UIButton*)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Saved Games" message:@"Are you sure you want to clear all the previous games?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if ([SavedGameOperation removeAllEntriesFromSavedGames]) {
                [self loadSavedGames];
                [UIAlertView bk_showAlertViewWithTitle:@"Scores" message:@"Successfully cleared all games from database" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
            } else {
                [UIAlertView bk_showAlertViewWithTitle:@"Scores" message:@"Failed to clear stored games from database" cancelButtonTitle:@"OK" otherButtonTitles:@[@"Retry" ] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [self clearAllScoresButtonPressed:nil];
                    }
                }];
            }
        }
    }];
}



@end
