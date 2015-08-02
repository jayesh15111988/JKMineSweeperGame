//
//  SaveGameModel.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "RLMObject.h"
#import "JKMineSweeperConstants.h"

@interface SaveGameModel : RLMObject

@property NSString* identifier;
@property NSString* savedGameName;
@property NSData* savedGameData;
@property NSInteger levelNumber;
@property NSString* numberOfTilesInRow;
@property double timestampOfSave;
@property NSInteger successiveTilesDistanceIncrement;
@property NSInteger score;

@end
