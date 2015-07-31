//
//  RandomNumberGenerator.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 7/30/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import "RandomNumberGenerator.h"

@implementation RandomNumberGenerator

+ (NSInteger)randomNumberBetweenMin:(NSInteger)minValue andMax:(NSInteger)maxValue {
    return arc4random() % (maxValue - minValue) + minValue;
}

@end
