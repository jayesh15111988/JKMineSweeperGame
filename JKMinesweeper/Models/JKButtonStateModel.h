//
//  JKButtonStateModel.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

enum {
    TileNotSelected,
    TileSelected,
    TileQuestionMarked
};
typedef NSUInteger TileStateRepresentationValue;

@interface JKButtonStateModel : NSObject
@property (nonatomic,assign) BOOL isThisButtonMine;
@property (nonatomic, assign) TileStateRepresentationValue currentTileState;
@property (nonatomic,assign)  NSInteger numberOfNeighboringMines;
@property (nonatomic,strong) NSArray* sequenceOfNeighbouringTiles;
@end