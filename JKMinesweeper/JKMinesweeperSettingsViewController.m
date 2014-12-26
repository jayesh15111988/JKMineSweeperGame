//
//  JKMinesweeperSettingsViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKMinesweeperSettingsViewController.h"

@interface JKMinesweeperSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIStepper *tileWidthStepper;
@property (weak, nonatomic) IBOutlet UISwitch *soundEffectSwitch;
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
}


- (IBAction)stepperValueChanged:(UIStepper *)sender {
    
    NSString* currentStepperValue = [NSString stringWithFormat:@"%ld",(long)sender.value];
    
    if(sender == self.tileWidthStepper) {
        self.tileWidthLabel.text = currentStepperValue;
    }
    else if(sender == self.gutterSpacingStepper) {
        self.gutterSpaceLabel.text = currentStepperValue;
    }
}

- (IBAction)soundSwitchChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.isOn) forKey:@"sound"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setObject:self.tileWidthLabel.text forKey:@"tileWidth"];
    [[NSUserDefaults standardUserDefaults] setObject:self.gutterSpaceLabel.text forKey:@"gutterSpacing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
