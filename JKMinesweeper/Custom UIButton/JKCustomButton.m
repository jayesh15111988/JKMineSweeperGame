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
#import <FLAnimatedImageView.h>

@interface JKCustomButton ()

@property (strong, nonatomic) FLAnimatedImageView* overlayImageView;

@end

@implementation JKCustomButton

- (JKCustomButton *)initWithPosition:(CGPoint)buttonPositionOnScreen
                             andWidth:(NSInteger)tileWidth
                           andIsMine:(BOOL)isMine
             andButtonSequenceNumber:(NSInteger)buttonSequenceNumber
         andNumberOfSurroundingMines:(NSInteger)numberOfSurroundingMines {

    self = [super init];

    if (self) {
        self.positionOnScreen = buttonPositionOnScreen;
        self.buttonStateModel = [JKButtonStateModel new];
        self.buttonSequenceNumber = buttonSequenceNumber;
        self.buttonStateModel.currentTileState = TileNotSelected;
        self.buttonStateModel.isThisButtonMine = isMine;
        self.buttonStateModel.numberOfNeighboringMines = numberOfSurroundingMines;
        self.alpha = 0.0;
        // 0 55 110 165 220 275
        
        self.frame =
            CGRectMake(buttonPositionOnScreen.x, buttonPositionOnScreen.y,
                       tileWidth, tileWidth);
        _overlayImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, tileWidth, tileWidth)];
        _overlayImageView.alpha = 0.0;
        [self addSubview:_overlayImageView];
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
            titleColor = [UIColor yellowColor];
        }

        [self setTitleColor:titleColor forState:UIControlStateNormal];

        [self addTarget:self
                      action:@selector(tileButtonSelected:)
            forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)updateOverlayImageRegularImage:(UIImage*)regularImage {
    _overlayImageView.alpha = 1.0;
    _overlayImageView.image = regularImage;
}

- (void)updateOverlayImageAnimatedImage:(FLAnimatedImage*)animatedImage {
    _overlayImageView.alpha = 1.0;
    _overlayImageView.animatedImage = animatedImage;
}

-(void)configurePreviousButton:(CGPoint)buttonPositionOnScreen andWidth:(NSInteger)tileWidth andButtonState:(JKButtonStateModel*)previousButtonState {
    

    self.buttonStateModel = previousButtonState;
    self.frame =
    CGRectMake(buttonPositionOnScreen.x, buttonPositionOnScreen.y,
               tileWidth, tileWidth);
    
    // Change color of title based on number of surrounding mines for given
    // tile
    // While - Light blue - lightgreen
    NSInteger numberOfSurroundingMines = previousButtonState.numberOfNeighboringMines;
    UIColor *titleColor;
    if (numberOfSurroundingMines == 1) {
        titleColor = [UIColor blackColor];
    } else if (numberOfSurroundingMines < 4) {
        titleColor = [UIColor blueColor];
        
    }
    // Any Value >3
    else {
        titleColor = [UIColor yellowColor];
    }
    
    self.backgroundColor = [UIColor orangeColor];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (previousButtonState.currentTileState == TileSelected) {
        [self setBackgroundColor:[UIColor redColor]];
        [self setTitle:[NSString stringWithFormat:@"%ld",(long)numberOfSurroundingMines] forState:UIControlStateNormal];
    }
    else if (previousButtonState.currentTileState == TileQuestionMarked) {
        [self setTitle:@"?" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    
    [self addTarget:self
             action:@selector(tileButtonSelected:)
   forControlEvents:UIControlEventTouchUpInside];
    
}



- (IBAction)tileButtonSelected:(JKCustomButton *)sender {

    // Go in the block only if tile is not previously selected by the user
    DLog(@"%ld",(long)self.buttonStateModel.currentTileState);
    if (self.buttonStateModel.currentTileState == TileNotSelected || self.buttonStateModel.currentTileState == TileQuestionMarked) {
        self.buttonStateModel.currentTileState = TileSelected;

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
        DLog(@"Tile was already selected");
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSValue valueWithCGPoint:self.positionOnScreen] forKey:@"positionOnScreen"];
    [coder encodeObject:self.buttonStateModel forKey:@"buttonStateModel"];
    [coder encodeObject:@(self.buttonSequenceNumber) forKey:@"buttonSequenceNumber"];
    [coder encodeObject:@(self.isVisited) forKey:@"isVisited"];

}
- (JKCustomButton*)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.positionOnScreen = [[decoder decodeObjectForKey:@"positionOnScreen"] CGPointValue];
        self.buttonStateModel = [decoder decodeObjectForKey:@"buttonStateModel"];
        self.buttonSequenceNumber = [[decoder decodeObjectForKey:@"buttonSequenceNumber"] integerValue];
        self.isVisited = [[decoder decodeObjectForKey:@"isVisited"] boolValue];
    }
    return self;
}

@end
