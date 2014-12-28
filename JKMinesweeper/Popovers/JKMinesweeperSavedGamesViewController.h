//
//  JKMinesweeperSavedGamesViewController.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SaveGameModel;

@interface JKMinesweeperSavedGamesViewController : UIViewController
typedef void (^SavedGameSelected)(SaveGameModel* selectedSavedGame);
@property (strong, nonatomic) SavedGameSelected openSelectedGameModel;
@end
