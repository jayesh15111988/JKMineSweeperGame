//
//  JKNeighbouringTilesProvider.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/30/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKNeighbouringTilesProvider : NSObject

+(NSArray*)getNeighbouringTilesForGivenTileWithSequence:(NSInteger)minesTileSequenceNumber andTotalTilesInSingleLine:(NSInteger)totalNumberOfTilesInRow;

@end
