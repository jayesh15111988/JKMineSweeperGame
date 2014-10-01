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
        // 0 55 110 165 220 275

        self.frame =
            CGRectMake(buttonPositionOnScreen.x, buttonPositionOnScreen.y,
                       DEFAULT_TILE_WIDTH, DEFAULT_TILE_WIDTH);

        //if (self.buttonStateModel.isThisButtonMine) {
            self.backgroundColor = [UIColor orangeColor];
       // } else {
         //   self.backgroundColor = [UIColor lightGrayColor];
        //}

        //[self setTitle:[NSString stringWithFormat:@"%d",
          //                                        self.buttonStateModel
            //                                          .numberOfNeighboringMines]
             // forState:UIControlStateNormal];
        [self addTarget:self
                      action:@selector(tileButtonSelected:)
            forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (IBAction)tileButtonSelected:(JKCustomButton *)sender {

    self.buttonStateModel.tileSelectedIndicator =
        !self.buttonStateModel.tileSelectedIndicator;


    if (self.buttonStateModel.isThisButtonMine) {
        // Game Over for player
        if (self.gameOverInstant) {
            self.gameOverInstant();
        }
    } else {
      //  self.backgroundColor = sender.buttonStateModel.tileSelectedIndicator
        //                           ? [UIColor greenColor]
          //                         : [UIColor lightGrayColor];
        //User has selected normal slide now, go and highlight all its neighbours
        if(self.randomTileSelectedInstant){
            self.randomTileSelectedInstant(self.buttonSequenceNumber);
        }
    }
}

@end
