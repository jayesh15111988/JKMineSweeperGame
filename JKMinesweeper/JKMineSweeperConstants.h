//
//  JKMineSweeperConstants.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MINES_NOT_REVEALED_STATE 14
#define MINES_REVEALED_STATE 15
#define SELECT_LEVEL_TITLE @"Select Target Level"
#define REGULAR_ANIMATION_DURATION 0.3
#define MULTIPLE_ANIMATION_DURATION 0.04
#define GIF_IMAGE_ANIMATION_DURATION 2.5
#define HIDE_POPOVER_VIEW_NOTIFICATION @"dismissCurrentViewController"
#define TIMER_VALUE_CHANGED @"timer_changed"
// Logging macros
#ifdef DEBUG
#define DLog(xx, ...) NSLog (@"%s(%d): " xx, ((strrchr (__FILE__, '/') ?: __FILE__ - 1) + 1), __LINE__, ##__VA_ARGS__)
#else
#define DLog(xx, ...) ((void)0)
#endif

@interface JKMineSweeperConstants : NSObject
@end
