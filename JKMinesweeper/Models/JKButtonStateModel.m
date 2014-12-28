//
//  JKButtonStateModel.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKButtonStateModel.h"

@implementation JKButtonStateModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.isThisButtonMine) forKey:@"isThisButtonMine"];
    [coder encodeObject:@(self.currentTileState) forKey:@"currentTileState"];
    [coder encodeObject:@(self.numberOfNeighboringMines) forKey:@"numberOfNeighboringMines"];
    [coder encodeObject:self.sequenceOfNeighbouringTiles forKey:@"sequenceOfNeighbouringTiles"];
    
}
- (JKButtonStateModel*)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.isThisButtonMine = [[decoder decodeObjectForKey:@"isThisButtonMine"] boolValue];
        self.currentTileState = [[decoder decodeObjectForKey:@"currentTileState"] integerValue];
        self.numberOfNeighboringMines = [[decoder decodeObjectForKey:@"numberOfNeighboringMines"] integerValue];
        self.sequenceOfNeighbouringTiles = [decoder decodeObjectForKey:@"sequenceOfNeighbouringTiles"];
    }
    return self;
}

@end
