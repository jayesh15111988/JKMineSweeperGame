//
//  UIView+Utility.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "UIView+Utility.h"

@implementation UIView (Utility)
-(void)addBorderWithColor:(UIColor*)color andWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}
@end
