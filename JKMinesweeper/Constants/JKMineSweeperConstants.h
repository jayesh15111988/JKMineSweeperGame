//
//  JKMineSweeperConstants.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#define MINES_NOT_REVEALED_STATE 14
#define MINES_REVEALED_STATE 15

#define REGULAR_ANIMATION_DURATION 0.5
#define MULTIPLE_ANIMATION_DURATION 0.4
#define GIF_IMAGE_ANIMATION_DURATION 2.0
#define DEFAULT_TOTAL_ANIMATION_DURATION 2.0
#define DEFAULT_BLAST_ANIMATION_DURATION 2.0

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define ANIMATED_IMAGE_URL @"http://bigpinekey.com/wp-content/uploads/an_exploding_bomb.gif"

#define cellIdentifier @"JKScoresCustomTableViewCell"

#define HIDE_POPOVER_VIEW_NOTIFICATION @"dismissCurrentViewController"
#define TIMER_VALUE_CHANGED @"timer_changed"
#define SOUND_SETTINGS_CHANGED @"soundSettingsChanged"

//Define enums used in the program
enum {
    NotStarted,
    InProgress,
    OverAndWin,
    OverAndLoss,
    Busy
};


enum {
    Foreground,
    Background,
    Timer
};

enum {
    NewGame,
    SavedGame
};

enum {
    ColorStateTileForegroundColor,
    ColorStateGridBackgroundColor
};

typedef NSUInteger CurrentGameState;
typedef NSUInteger SoundCategory;
typedef NSUInteger GameState;
typedef NSUInteger ColorState;


@interface JKMineSweeperConstants : NSObject
@end
