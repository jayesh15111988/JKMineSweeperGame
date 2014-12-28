//
//  Sample.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/27/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "Sample.h"

@implementation Sample

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.p1 forKey:@"p1"];
    [coder encodeObject:[NSValue valueWithCGPoint:self.p2] forKey:@"p2"];
    [coder encodeObject:@(self.p3) forKey:@"p3"];
    [coder encodeObject:@(self.p4) forKey:@"p4"];
    
}
- (Sample*)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.p1 = [decoder decodeObjectForKey:@"p1"];
        self.p2 = [[decoder decodeObjectForKey:@"p2"] CGPointValue];
        self.p3 = [[decoder decodeObjectForKey:@"p3"] integerValue];
        self.p4 = [[decoder decodeObjectForKey:@"p4"] boolValue];
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ %d, %d",self.p1,NSStringFromCGPoint(self.p2),self.p3,self.p4];
}

@end
