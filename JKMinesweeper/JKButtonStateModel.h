//
//  JKButtonStateModel.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKButtonStateModel : NSObject
@property (nonatomic,assign) BOOL isThisButtonMine;
@property (nonatomic,assign) BOOL tileSelectedIndicator;
@property (nonatomic,assign)  NSInteger numberOfNeighboringMines;
@end