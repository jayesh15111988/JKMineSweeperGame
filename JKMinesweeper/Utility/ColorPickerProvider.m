//
//  ColorPickerProvider.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 7/30/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import "ColorPickerProvider.h"
#import <HRColorPickerView.h>
#import <ReactiveCocoa.h>
#import "JKMineSweeperConstants.h"

static HRColorPickerView* colorPickerView;

@implementation ColorPickerProvider

+ (UIView*)colorPickerForCurrentViewForParentView:(UIView*)parentView andColorChangedBlock:(void (^)(UIColor* selectedColor))colorChangedBlock {
    UIView* colorPickerHolderView = [UIView new];
    colorPickerHolderView.translatesAutoresizingMaskIntoConstraints = NO;
    colorPickerView = [[HRColorPickerView alloc] init];
    colorPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    colorPickerView.color = parentView.backgroundColor;
    colorPickerView.colorInfoView.alpha = 0.0;
    
    [[colorPickerView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(HRColorPickerView* colorPicker) {
        colorChangedBlock(colorPicker.color);
    }];
    
    UIButton* hideColorPickerButton = [[UIButton alloc] init];
    hideColorPickerButton.translatesAutoresizingMaskIntoConstraints = NO;
    hideColorPickerButton.backgroundColor = [UIColor yellowColor];
    [hideColorPickerButton setTitle:@"OK" forState:UIControlStateNormal];
    [hideColorPickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[hideColorPickerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [UIView animateWithDuration:REGULAR_ANIMATION_DURATION animations:^{
           colorPickerHolderView.alpha = 0.0; 
        }];
    }];
    
    [colorPickerHolderView addSubview:colorPickerView];
    [colorPickerHolderView addSubview:hideColorPickerButton];
    [parentView addSubview:colorPickerHolderView];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:colorPickerHolderView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:colorPickerHolderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:colorPickerHolderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:300]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:colorPickerHolderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:354]];
    
    // Add Constraints to actual Color Picker where you would choose colors from.
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPickerView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(colorPickerView)]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorPickerView(300)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(colorPickerView)]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hideColorPickerButton]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(hideColorPickerButton)]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[colorPickerView]-10-[hideColorPickerButton(44)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(colorPickerView, hideColorPickerButton)]];
    return colorPickerHolderView;
}

+ (void)changeColorPickerColorWithNewColor:(UIColor*)updatedColor {
    colorPickerView.color = updatedColor;
}

@end
