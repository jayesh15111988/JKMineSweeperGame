//
//  JKTimerProviderUtility.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKTimerProviderUtility.h"
#import "JKAudioOperations.h"

@interface JKTimerProviderUtility ()
@property (assign, nonatomic) NSInteger currentNumberOfSeconds;
@property (strong, nonatomic) NSTimer* timer;

//Parameters to keep track of timer time when it is paused for a while
@property (strong, nonatomic) NSDate* pauseStart;
@property (strong, nonatomic) NSDate* previousFireDate;
@property (assign, nonatomic) BOOL isSoundEffectOn;
@property (strong, nonatomic) JKAudioOperations* audioOperationManager;
@end

@implementation JKTimerProviderUtility

-(JKTimerProviderUtility*)init {
    if (self = [super init]) {
        self.currentNumberOfSeconds = 0;
        self.currentTimerState = TimerNotStarted;
        self.audioOperationManager = [[JKAudioOperations alloc] init];
        return self;
    }
    return nil;
}

-(void)increaseTimerCount {
        self.currentNumberOfSeconds++;
        if (self.timer.isValid) {
            self.UpdateTimerLabelBlock([self getMinutesAndSecondsStringFromSeconds]);
        }
}

-(NSString*)getMinutesAndSecondsStringFromSeconds {
    
    if (self.isSoundEffectOn) {
        //Play this cukoo alarm once every minute to give sense of current time
        if (self.currentNumberOfSeconds % 60 == 0) {
            [self.audioOperationManager playForegroundSoundFXnamed:@"clockcirclecomplete.wav" loop:NO];
        }
    }
    
    NSInteger minutes = self.currentNumberOfSeconds / 60;
    NSInteger seconds = self.currentNumberOfSeconds % 60;
    return [NSString stringWithFormat:@"%02ld : %02ld",(long)minutes, (long)seconds];
}


-(void)startTimer {
    if (self.currentTimerState == TimerNotStarted) {
        self.isSoundEffectOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
        [self.timer fire];
        self.currentTimerState = TimerIsPlaying;
    }
    else if (self.currentTimerState == TimerIsPaused) {
        CGFloat pauseTime = -1*[self.pauseStart timeIntervalSinceNow];
        [self.timer setFireDate:[NSDate dateWithTimeInterval:pauseTime sinceDate:self.previousFireDate]];
        self.currentTimerState = TimerIsPlaying;
    }
}
-(void)pauseTimer {
        self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
        self.previousFireDate = [self.timer fireDate];
        [self.timer setFireDate:[NSDate distantFuture]];
        self.currentTimerState = TimerIsPaused;
}

-(void)resetTimer {
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    self.currentNumberOfSeconds = 0;
    self.currentTimerState = TimerNotStarted;
    self.UpdateTimerLabelBlock(@"00 : 00");
}
@end
