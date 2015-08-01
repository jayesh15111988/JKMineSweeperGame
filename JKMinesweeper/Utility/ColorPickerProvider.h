//
//  ColorPickerProvider.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 7/30/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HRColorPickerView;

@interface ColorPickerProvider : NSObject

+ (HRColorPickerView*)colorPickerForCurrentViewForParentView:(UIView*)parentView andColorChangedBlock:(void (^)(UIColor* selectedColor))colorChangedBlock;
+ (void)changeColorPickerColorWithNewColor:(UIColor*)updatedColor;

@end
