//
//  RandomNumberGenerator.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 7/30/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomNumberGenerator : NSObject

+ (NSInteger)randomNumberBetweenMin:(NSInteger)minValue andMax:(NSInteger)maxValue;

@end
