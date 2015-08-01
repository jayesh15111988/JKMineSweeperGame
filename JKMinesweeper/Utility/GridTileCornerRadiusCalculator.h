//
//  GridTileCornerRadiusCalculator.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 8/1/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKMineSweeperConstants.h"

@interface GridTileCornerRadiusCalculator : NSObject

+ (CGFloat)buttonBorderRadiusFromType:(GridButtonType)buttonType andTileWidth:(CGFloat)tileWidth;

@end
