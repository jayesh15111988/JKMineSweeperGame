//
//  JKCustomButton.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKButtonStateModel;



@interface JKCustomButton : UIButton

-(JKCustomButton*)initWithPosition:(CGPoint)buttonPositionOnScreen andIsMine:(BOOL)isMine andButtonSequenceNumber:(NSInteger)buttonSequenceNumber andNumberOfSurroundingMines:(NSInteger)numberOfSurroundingMines;
@property (nonatomic,assign) CGPoint positionOnScreen;
@property (nonatomic,strong) JKButtonStateModel* buttonStateModel;
@property (nonatomic,assign) NSInteger buttonSequenceNumber;

typedef void (^gameOverBlock)();
@property(strong, nonatomic) gameOverBlock gameOverInstant;
@end
