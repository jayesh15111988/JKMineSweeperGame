//
//  JKButtonStateModel.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    TileIsNotSelected,
    TileIsSelected,
    TileIsQuestionMarked
};
typedef NSInteger TileStateRepresentationValue;

@interface JKButtonStateModel : NSObject
@property (nonatomic,assign) BOOL isThisButtonMine;
//@property (nonatomic,assign) BOOL tileSelectedIndicator;
//@property (nonatomic, assign) BOOL isQuestionMarked;
@property (nonatomic, assign) TileStateRepresentationValue currentTileState;
@property (nonatomic,assign)  NSInteger numberOfNeighboringMines;
@property (nonatomic,strong) NSArray* sequenceOfNeighbouringTiles;
@end