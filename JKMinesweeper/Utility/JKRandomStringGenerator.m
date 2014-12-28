//
//  JKRandomStringGenerator.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKRandomStringGenerator.h"

static NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";

@implementation JKRandomStringGenerator
+(NSString*)generateRandomStringWithLength:(NSInteger)randomStringLength {
    
    NSMutableString *s = [NSMutableString stringWithCapacity:randomStringLength];
    for (NSUInteger i = 0; i < randomStringLength; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}
@end
