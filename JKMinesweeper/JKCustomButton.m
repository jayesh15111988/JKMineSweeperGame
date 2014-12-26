//
//  JKCustomButton.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKCustomButton.h"
#import "JKButtonStateModel.h"
#import "JKMineSweeperConstants.h"

@implementation JKCustomButton

- (JKCustomButton *)initWithPosition:(CGPoint)buttonPositionOnScreen
                           andIsMine:(BOOL)isMine
             andButtonSequenceNumber:(NSInteger)buttonSequenceNumber
         andNumberOfSurroundingMines:(NSInteger)numberOfSurroundingMines {

    self = [super init];

    if (self) {
        self.positionOnScreen = buttonPositionOnScreen;
        self.buttonStateModel = [JKButtonStateModel new];
        self.buttonSequenceNumber = buttonSequenceNumber;
        self.buttonStateModel.tileSelectedIndicator = NO;
        self.buttonStateModel.isThisButtonMine = isMine;
        self.buttonStateModel.numberOfNeighboringMines =
            numberOfSurroundingMines;
        self.isInLongPressedMode = NO;
        self.alpha = 0.0;
        // 0 55 110 165 220 275

        self.frame =
            CGRectMake(buttonPositionOnScreen.x, buttonPositionOnScreen.y,
                       DEFAULT_TILE_WIDTH, DEFAULT_TILE_WIDTH);

        // Change color of title based on number of surrounding mines for given
        // tile
        // While - Light blue - lightgreen
        UIColor *titleColor;
        if (numberOfSurroundingMines == 1) {
            titleColor = [UIColor blackColor];
        } else if (numberOfSurroundingMines < 4) {
            titleColor = [UIColor blueColor];

        }
        // Any Value >3
        else {
            titleColor = [UIColor redColor];
        }

        self.backgroundColor = [UIColor orangeColor];
        [self setTitleColor:titleColor forState:UIControlStateNormal];

        [self addTarget:self
                      action:@selector(tileButtonSelected:)
            forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (IBAction)tileButtonSelected:(JKCustomButton *)sender {

    // Go in the block only if tile is not previously selected by the user
    if (!self.buttonStateModel.tileSelectedIndicator) {
        self.buttonStateModel.tileSelectedIndicator =
            !self.buttonStateModel.tileSelectedIndicator;

        if (self.buttonStateModel.isThisButtonMine) {
            // Game Over for player
            if (self.gameOverInstant) {
                self.gameOverInstant();
            }
        } else {
            // Any tile is selected by user
            if (self.randomTileSelectedInstant) {
                self.randomTileSelectedInstant(self.buttonSequenceNumber);
            }
        }
    } else {
        NSLog(@"Tile was already selected");
    }
}

@end
