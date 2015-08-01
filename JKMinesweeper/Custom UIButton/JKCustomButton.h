//
//  JKCustomButton.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

@class JKButtonStateModel;
@class FLAnimatedImage;


@interface JKCustomButton : UIButton

- (JKCustomButton*)initWithPosition:(CGPoint)buttonPositionOnScreen andWidth:(NSInteger)tileWidth andIsMine:(BOOL)isMine andButtonSequenceNumber:(NSInteger)buttonSequenceNumber andNumberOfSurroundingMines:(NSInteger)numberOfSurroundingMines;

- (void)configurePreviousButton:(CGPoint)buttonPositionOnScreen andWidth:(NSInteger)tileWidth andButtonState:(JKButtonStateModel*)previousButtonState;

@property (nonatomic,assign) CGPoint positionOnScreen;
@property (nonatomic,strong) JKButtonStateModel* buttonStateModel;
@property (nonatomic,assign) NSInteger buttonSequenceNumber;
@property (nonatomic,assign) BOOL isVisited;

typedef void (^gameOverBlock)();
@property(strong, nonatomic) gameOverBlock gameOverInstant;

typedef void (^randomTileSelected)();
@property(strong, nonatomic) randomTileSelected randomTileSelectedInstant;

- (void)updateOverlayImageRegularImage:(UIImage*)regularImage;
- (void)updateOverlayImageAnimatedImage:(FLAnimatedImage*)animatedImage;

@end
