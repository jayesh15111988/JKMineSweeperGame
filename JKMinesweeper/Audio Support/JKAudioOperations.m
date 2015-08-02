//
//  JKAudioOperations.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKAudioOperations.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface JKAudioOperations ()
@property (strong, nonatomic) AVAudioPlayer *foreGroundPlayer;
@property (strong, nonatomic) AVAudioPlayer *backGroundPlayer;
@end

@implementation JKAudioOperations

-(JKAudioOperations*)init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}


-(BOOL)isSoundOn {
    BOOL isSoundEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
    return isSoundEnabled;
}

-(BOOL) playForegroundSoundFXnamed: (NSString*) vSFXName loop: (BOOL) vLoop {
    
    if (![self isSoundOn]) {
        return NO;
    }
    
    NSError *error;
    NSURL* currentFileURL = [self getFullURLForFileWithName:vSFXName];
    
    if (!currentFileURL) {
        return NO;
    }
    
    self.foreGroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentFileURL error:&error];
    
    
    if (vLoop) {
        self.foreGroundPlayer.numberOfLoops = -1;
    } else {
        self.foreGroundPlayer.numberOfLoops = 0;
    }
    
    BOOL success = YES;
    
    if (self.foreGroundPlayer == nil) {
        success = NO;
    } else {
        success = [self.foreGroundPlayer play];
    }
    return success;
}

-(BOOL) playBackgroundSoundFXnamed: (NSString*) vSFXName loop: (BOOL) vLoop {
    
    if (![self isSoundOn]) {
        return NO;
    }
    
    NSError *error;
    NSURL* currentFileURL = [self getFullURLForFileWithName:vSFXName];
    
    if (!currentFileURL) {
        return NO;
    }
    
    self.backGroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentFileURL error:&error];
    
    
    if (vLoop) {
        self.backGroundPlayer.numberOfLoops = -1;
    } else {
        self.backGroundPlayer.numberOfLoops = 0;
    }
    
    BOOL success = YES;
    
    if (self.backGroundPlayer == nil) {
        success = NO;
    } else {
        success = [self.backGroundPlayer play];
    }
    return success;
}


-(NSURL*)getFullURLForFileWithName:(NSString*)fileName {
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* bundleDirectory = (NSString*)[bundle bundlePath];
    return [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:fileName]];
}

-(void)stopBackgroundMusic {
    [self.backGroundPlayer stop];
}

-(void)stopForegroundMusic {
    [self.foreGroundPlayer stop];
}

@end
