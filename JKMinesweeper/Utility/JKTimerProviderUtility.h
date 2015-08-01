//
//  JKTimerProviderUtility.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

enum {
    TimerNotStarted,
    TimerIsPlaying,
    TimerIsPaused
};
typedef NSUInteger TimerState;

@interface JKTimerProviderUtility : NSObject
@property (assign, nonatomic) TimerState currentTimerState;
-(JKTimerProviderUtility*)init;
-(void)startTimer;
-(void)pauseTimer;
-(void)resetTimer;
typedef void (^TimerValueUpdated)(NSString* currentTimeValue);
@property (strong, nonatomic) TimerValueUpdated UpdateTimerLabelBlock;
@end
