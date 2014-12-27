//
//  JKMinesweeperSettingsViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKMinesweeperSettingsViewController.h"
#import "JKMineSweeperConstants.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <ReactiveCocoa.h>

@interface JKMinesweeperSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIStepper *tileWidthStepper;
@property (weak, nonatomic) IBOutlet UISwitch *soundEffectSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timerSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *gutterSpacingStepper;
@property (weak, nonatomic) IBOutlet UILabel *tileWidthLabel;
@property (weak, nonatomic) IBOutlet UILabel *gutterSpaceLabel;

@end

@implementation JKMinesweeperSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tileWidthLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"tileWidth"];
    self.gutterSpaceLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"gutterSpacing"];
    self.tileWidthStepper.value = [self.tileWidthLabel.text integerValue];
    self.gutterSpacingStepper.value = [self.gutterSpaceLabel.text integerValue];
    
    [RACObserve(self, tileWidthStepper.value) subscribeNext:^(NSNumber* newTileWidth) {
        NSString* currentStepperValue = [NSString stringWithFormat:@"%ld",(long)[newTileWidth integerValue]];
        self.tileWidthLabel.text = currentStepperValue;
        [[NSUserDefaults standardUserDefaults] setObject:self.tileWidthLabel.text forKey:@"tileWidth"];
    }];
    
    [RACObserve(self, gutterSpacingStepper.value) subscribeNext:^(NSNumber *newGutterWidth) {
        NSString* currentStepperValue = [NSString stringWithFormat:@"%ld",(long)[newGutterWidth integerValue]];
        self.gutterSpaceLabel.text = currentStepperValue;
        [[NSUserDefaults standardUserDefaults] setObject:self.gutterSpaceLabel.text forKey:@"gutterSpacing"];
    }];
}

- (IBAction)dismissCurrentViewPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_POPOVER_VIEW_NOTIFICATION object:nil];
}

- (IBAction)soundSwitchChanged:(UISwitch *)sender {
    if(sender == self.soundEffectSwitch) {
        [[NSUserDefaults standardUserDefaults] setObject:@(sender.isOn) forKey:@"sound"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@(sender.isOn) forKey:@"timer"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TIMER_VALUE_CHANGED object:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
