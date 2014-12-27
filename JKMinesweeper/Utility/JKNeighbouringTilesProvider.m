//
//  JKNeighbouringTilesProvider.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/30/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKNeighbouringTilesProvider.h"

static NSInteger topRightCorner;
static NSInteger bottomLeftCorner;

@implementation JKNeighbouringTilesProvider

+(NSArray*)getNeighbouringTilesForGivenTileWithSequence:(NSInteger)minesTileSequenceNumber andTotalTilesInSingleLine:(NSInteger)totalNumberOfTilesInRow{
    
    NSArray* resultantNeightbors=@[];
    
     topRightCorner = totalNumberOfTilesInRow - 1;
     bottomLeftCorner = (totalNumberOfTilesInRow)*topRightCorner;
    
    if (minesTileSequenceNumber == 0) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber + 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow + 1)
                                ];
    } else if (minesTileSequenceNumber == topRightCorner) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber - 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow)
                                ];
        
    } else if (minesTileSequenceNumber == bottomLeftCorner) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber + 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow + 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow)
                                ];
        
    } else if (minesTileSequenceNumber ==
               topRightCorner + bottomLeftCorner) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber - 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow)
                                ];
        
    }
    // Top horizontal Row
    else if (minesTileSequenceNumber < topRightCorner) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber - 1),
                                @(minesTileSequenceNumber + 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow + 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow)
                                ];
        
    }
    // Extreme right vertical row
    else if ((minesTileSequenceNumber + 1) % totalNumberOfTilesInRow ==
             0) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber - 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow - 1)
                                ];
        
    }
    // Extreme left vertical row
    else if (minesTileSequenceNumber % totalNumberOfTilesInRow == 0) {
        
        resultantNeightbors = @[
                                @(minesTileSequenceNumber + 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow + 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow + 1)
                                ];
        
    }
    // Bottom horizontal row
    else if (minesTileSequenceNumber > bottomLeftCorner) {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber - 1),
                                @(minesTileSequenceNumber + 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow + 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow)
                                ];
        
    }
    // Any tile inside grid and not touching any adjacent boundary
    else {
        resultantNeightbors = @[
                                @(minesTileSequenceNumber - 1),
                                @(minesTileSequenceNumber + 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber + totalNumberOfTilesInRow + 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow - 1),
                                @(minesTileSequenceNumber - totalNumberOfTilesInRow + 1)
                                ];
    }
    

    return resultantNeightbors;
}
@end
