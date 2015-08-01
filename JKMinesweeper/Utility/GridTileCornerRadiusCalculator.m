//
//  GridTileCornerRadiusCalculator.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 8/1/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import "GridTileCornerRadiusCalculator.h"
#import "JKMineSweeperConstants.h"

@implementation GridTileCornerRadiusCalculator

+ (CGFloat)buttonBorderRadiusFromType:(GridButtonType)buttonType andTileWidth:(CGFloat)tileWidth {
    CGFloat buttonCornerRadius = 0;
    switch (buttonType) {
        case GridButtonTypeRoundedBorder:
            buttonCornerRadius= tileWidth/4.0;
            break;
        case GridButtonTypeCircle:
            buttonCornerRadius = tileWidth/2.0;
            break;
        default:
            break;
    }
    return buttonCornerRadius;
}


@end
