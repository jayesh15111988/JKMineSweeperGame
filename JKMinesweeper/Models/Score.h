//
//  Score.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "RLMObject.h"

@interface Score : RLMObject
@property NSString* userName;
@property NSInteger scrore;
@property double timestamp;
@property NSInteger gameLevel;
@end
