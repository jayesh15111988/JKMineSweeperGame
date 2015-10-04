//
//  JKiPhoneSettingsViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 10/2/15.
//  Copyright (c) 2015 Jayesh Kawli. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "JKMinesweeperHomeViewController.h"
#import "SaveGameModel.h"
#import "JKiPhoneSettingsViewController.h"

@interface JKiPhoneSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *gridSizeInputTextField;
@property (assign, nonatomic) NSInteger currentLevelNumber;
@property (weak, nonatomic) IBOutlet UIButton *currentLevelButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation JKiPhoneSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Options";
    self.gridSizeInputTextField.inputAccessoryView = self.toolbar;
    
    @weakify(self)
    [[self.gridSizeInputTextField rac_textSignal] subscribeNext:^(NSString* inputFieldText) {
        @strongify(self)
        [self.minesweeperHomeViewController updateGridSizeWithNewGridSize:[inputFieldText integerValue]];
    }];
    
    [RACObserve(self, minesweeperHomeViewController.inputGridDimensionSize) subscribeNext:^(NSNumber* inputGridCurrentSize) {
        self.gridSizeInputTextField.text = [NSString stringWithFormat:@"%@", inputGridCurrentSize];
    }];
    
    [RACObserve(self, minesweeperHomeViewController.levelNumberSelected) subscribeNext:^(NSNumber* currentLevelNumber) {
        self.currentLevelNumber = [currentLevelNumber integerValue];
        [self.currentLevelButton setTitle:[NSString stringWithFormat:@"Level: %ld", (long)self.currentLevelNumber] forState:UIControlStateNormal];
    }];
}

- (IBAction)saveGameButtonPressed:(id)sender {
    [self.minesweeperHomeViewController saveOngoingGame];
}

- (IBAction)loadGameButtonPressed:(id)sender {
    [self.minesweeperHomeViewController loadPreviousGame];
}

- (IBAction)verifyButtonPressed:(id)sender {
    [self.minesweeperHomeViewController verifyCurrentGame];
}

- (IBAction)changeLevelButtonPressed:(id)sender {
    [self.minesweeperHomeViewController levelNumberButtonPressed];
}

- (IBAction)openMoreSettingsOptionPressed:(id)sender {
    [self.minesweeperHomeViewController openMoreSettingsOption];
}
- (IBAction)doneButtonPressed:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)goToSavedScores:(id)sender {
    [self.minesweeperHomeViewController showPastScores];
}


@end
