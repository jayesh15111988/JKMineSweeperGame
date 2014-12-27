//
//  ScoreSaver.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Realm.h>
#import "ScoreSaver.h"
#import "Score.h"

@implementation ScoreSaver

+(void)saveScoreInDatabaseWithUserName:(NSString*)userName andScoreValue:(NSString*)currentScore andSelectedGameLevel:(NSInteger)gameLevel{
    
    RLMRealm* currentRealm = [RLMRealm defaultRealm];
    Score* scoreObject = [Score new];
    scoreObject.userName = userName;
    scoreObject.scrore = [currentScore integerValue];
    scoreObject.timestamp = [[NSDate date] timeIntervalSince1970];
    scoreObject.gameLevel = gameLevel;
    NSLog(@"%@",scoreObject);
    [currentRealm beginWriteTransaction];
    [currentRealm addObject:scoreObject];
    [currentRealm commitWriteTransaction];
}

+(RLMResults*)getAllScoresFromDatabase {
    return [Score allObjects];
    
}
@end