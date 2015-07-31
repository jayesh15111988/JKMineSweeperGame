//
//  JKAudioOperations.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKAudioOperations : NSObject
- (BOOL)playForegroundSoundFXnamed:(NSString*)vSFXName loop:(BOOL) vLoop;
- (BOOL)playBackgroundSoundFXnamed:(NSString*)vSFXName loop:(BOOL) vLoop;
- (void)stopBackgroundMusic;
- (void)stopForegroundMusic;
@end
