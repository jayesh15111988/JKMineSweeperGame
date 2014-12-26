//
//  ScoreSaver.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RLMResults.h>

@interface ScoreSaver : NSObject
+(void)saveScoreInDatabaseWithUserName:(NSString*)userName andScoreValue:(NSString*)currentScore andSelectedGameLevel:(NSInteger)gameLevel;
+(RLMResults*)getAllScoresFromDatabase;
@end
