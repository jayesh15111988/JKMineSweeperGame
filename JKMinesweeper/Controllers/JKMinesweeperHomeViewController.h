//
//  JKMinesweeperHomeViewController.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

@class SaveGameModel;

@interface JKMinesweeperHomeViewController : UIViewController

@property (nonatomic, strong, readonly) SaveGameModel* savedGameModel;
@property (nonatomic, assign) NSInteger inputGridDimensionSize;
@property (assign, nonatomic) NSInteger levelNumberSelected;

- (void)saveOngoingGame;
- (void)loadPreviousGame;
- (void)updateGridSizeWithNewGridSize:(NSInteger)gridSize;
- (void)verifyCurrentGame;
- (void)levelNumberButtonPressed;
- (void)openMoreSettingsOption;
- (void)showPastScores;

@end
