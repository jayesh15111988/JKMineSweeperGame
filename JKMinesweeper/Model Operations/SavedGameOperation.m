//
//  SavedGameOperation.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <RLMResults.h>
#import <RLMRealm.h>

#import "SavedGameOperation.h"
#import "SaveGameModel.h"

@implementation SavedGameOperation
+(BOOL)removeAllEntriesFromSavedGames {
    RLMResults* allSavedGames = [SaveGameModel allObjects];
    if ([allSavedGames count] > 0) {
        RLMRealm* currentRealm = [RLMRealm defaultRealm];
        [currentRealm beginWriteTransaction];
        [currentRealm deleteObjects:allSavedGames];
        [currentRealm commitWriteTransaction];
        return ([[SaveGameModel allObjects] count] == 0);
    }
    return YES;
}
@end
