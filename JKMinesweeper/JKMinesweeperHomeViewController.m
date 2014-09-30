//
//  JKMinesweeperHomeViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKMinesweeperHomeViewController.h"
#import "JKMineSweeperConstants.h"
#import "JKCustomButton.h"

typedef void (^ resetTilesFinishedBlock)();

@interface JKMinesweeperHomeViewController () <UIAlertViewDelegate>

@property(weak, nonatomic) IBOutlet UITextField *gridSizeInputText;
@property(weak, nonatomic) IBOutlet UIButton *createGridButton;
@property(strong, nonatomic) UIView *gridHolderView;
@property(strong, nonatomic) NSMutableDictionary *minesLocationHolder;
@property(strong, nonatomic) NSMutableArray *minesButtonsHolder;
@property(assign, nonatomic) NSInteger totalNumberOfRequiredTiles;
@property(strong, nonatomic)
    NSMutableDictionary *numberOfSurroundingMinesHolder;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)revealMinesButtonPressed:(id)sender;
@property(weak, nonatomic) IBOutlet UIButton *revealMenuButton;
@property(weak, nonatomic) IBOutlet UIButton *resetButton;

@property(assign, nonatomic) NSInteger topRightCorner;
@property(assign, nonatomic) NSInteger bottomLeftCorner;


@end

@implementation JKMinesweeperHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridHolderView = [[UIView alloc] init];
    self.minesLocationHolder = [NSMutableDictionary new];
    self.minesButtonsHolder = [NSMutableArray new];
    self.numberOfSurroundingMinesHolder = [NSMutableDictionary new];

    [self.createGridButton addTarget:self
                              action:@selector(createGridButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)createGridButtonPressed:(UIButton *)sender {


    self.revealMenuButton.tag = 14;

    self.totalNumberOfRequiredTiles =
        [self.gridSizeInputText.text integerValue];
    
    if(self.totalNumberOfRequiredTiles<3){
        self.totalNumberOfRequiredTiles=3;
    }
    
    [self createNewGridOnScreen];
}

- (void)createNewGridOnScreen {

    self.createGridButton.enabled=NO;
    self.resetButton.enabled=YES;
    self.revealMenuButton.enabled=YES;
    
    [self resetGridWithNewTilesAndCompletionBlock:nil];
    
    [self populateMinesHolderWithMinesLocationsWithMaximumGridWidth:
              self.totalNumberOfRequiredTiles];

    NSInteger gridHeightAndWidth =
        (DEFAULT_TILE_WIDTH * self.totalNumberOfRequiredTiles) +
        (DEFAULT_GUTTER_WIDTH * (self.totalNumberOfRequiredTiles - 1));
    CGFloat startingXPositionForGridView =
        self.view.center.x - (gridHeightAndWidth / 2);


    self.gridHolderView.frame =
        CGRectMake(startingXPositionForGridView, 125, gridHeightAndWidth,
                   gridHeightAndWidth);

    [self.gridHolderView setBackgroundColor:[UIColor lightGrayColor]];
    NSInteger buttonSequenceNumber = 0;
    BOOL doesMineExistForTile = NO;
    NSInteger totalNumberOfMinesSurroundingGivenTile = 0;

    for (NSInteger heightParamters = 0; heightParamters < gridHeightAndWidth;
         heightParamters += 55) {
        for (NSInteger widthParameter = 0; widthParameter < gridHeightAndWidth;
             widthParameter += 55) {

            buttonSequenceNumber =
                ((widthParameter / 55) +
                 (heightParamters / 55) * self.totalNumberOfRequiredTiles);
            doesMineExistForTile =
                self.minesLocationHolder[@(buttonSequenceNumber)] ? YES : NO;


            totalNumberOfMinesSurroundingGivenTile =
                [self.numberOfSurroundingMinesHolder[
                    @(buttonSequenceNumber)] integerValue];

            JKCustomButton *newRevealMineButton = [[JKCustomButton alloc]
                           initWithPosition:CGPointMake(widthParameter,
                                                        heightParamters)
                                  andIsMine:doesMineExistForTile
                    andButtonSequenceNumber:buttonSequenceNumber
                andNumberOfSurroundingMines:
                    totalNumberOfMinesSurroundingGivenTile];

            __weak typeof(self) weakSelf = self;

            newRevealMineButton.gameOverInstant = ^() {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf showAllMines];
                [strongSelf showGameOverAlertView];
            };

            if (doesMineExistForTile) {
                [self.minesButtonsHolder addObject:newRevealMineButton];
            }
            [self.gridHolderView addSubview:newRevealMineButton];
        }
    }

    [self.view addSubview:self.gridHolderView];
}

- (void)showGameOverAlertView {
    UIAlertView *gameOverAlertView = [[UIAlertView alloc]
            initWithTitle:@"Game Over"
                  message:@"You clicked on mine and game is now over"
                 delegate:self
        cancelButtonTitle:@"Start New Game"
        otherButtonTitles:nil];
    [gameOverAlertView show];
}


- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self resetGridWithNewTilesAndCompletionBlock:^{
            [self createNewGridOnScreen];
        }];
        
    }
}

- (void)populateMinesHolderWithMinesLocationsWithMaximumGridWidth:
            (NSInteger)maximumNumberOfTilesInRow {

    NSInteger maximumTileSequence = pow(maximumNumberOfTilesInRow, 2);

    NSInteger minesGeneratedSoFar = 0;
    NSInteger generateRandomMinesSequence = 0;


    // Variables to hold specific corners of box
    self.topRightCorner = maximumNumberOfTilesInRow - 1;
    self.bottomLeftCorner = (maximumNumberOfTilesInRow)*self.topRightCorner;


    while (minesGeneratedSoFar < MAXIMUM_NUMBER_OF_MINES) {

        generateRandomMinesSequence =
            [self getRandomNumberWithMinValue:0
                                  andMaxValue:maximumTileSequence];
        if (![self.minesLocationHolder
                objectForKey:@(generateRandomMinesSequence)]) {
            minesGeneratedSoFar++;
            [self getNeighboringValidCellsForGivenMineWithSequence:
                      generateRandomMinesSequence];

            [self.minesLocationHolder setObject:@"1"
                                         forKey:@(generateRandomMinesSequence)];
        }
    }
    NSLog(@"Generated mines %@", self.minesLocationHolder);
}

- (NSInteger)getRandomNumberWithMinValue:(NSInteger)minValue
                             andMaxValue:(NSInteger)maxValue {
    return arc4random() % (maxValue - minValue) + minValue;
}

- (IBAction)resetButtonPressed:(UIButton *)sender {
    [self resetGridWithNewTilesAndCompletionBlock:nil];
}

- (void)resetGridWithNewTilesAndCompletionBlock:(void (^)())resetTilesFinishedBlock {
    self.createGridButton.enabled = YES;
    self.resetButton.enabled = YES;
    self.revealMenuButton.enabled = YES;

    [self.minesLocationHolder removeAllObjects];
    [self.minesButtonsHolder removeAllObjects];
    [self.numberOfSurroundingMinesHolder removeAllObjects];

    dispatch_time_t time = DISPATCH_TIME_NOW;

    NSArray *allButtonsInGridView = [self.gridHolderView subviews];
    for (UIView *individualButtonOnGrid in allButtonsInGridView) {

        dispatch_after(time, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2
                animations:^{ individualButtonOnGrid.alpha = 0.0; }
                completion:^(BOOL finished) {
                    [individualButtonOnGrid removeFromSuperview];
                }];
        });
        time = dispatch_time(time, 0.04 * NSEC_PER_SEC);
    }
    if(resetTilesFinishedBlock){
    resetTilesFinishedBlock();
    }
}

- (IBAction)revealMinesButtonPressed:(UIButton *)sender {

    if (sender.tag == 14) {
        sender.tag = 15;
        sender.titleLabel.text = @"Hide";
        for (
            JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
            individualTileWithMine.backgroundColor = [UIColor greenColor];
        }
    } else {
        sender.tag = 14;
        sender.titleLabel.text = @"Reveal";
        for (
            JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
            individualTileWithMine.backgroundColor = [UIColor orangeColor];
        }
    }
}

- (void)getNeighboringValidCellsForGivenMineWithSequence:
            (NSInteger)minesTileSequenceNumber {

    NSArray *resultantNeightbors = @[];


    if (minesTileSequenceNumber == 0) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber + 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles + 1)
        ];
    } else if (minesTileSequenceNumber == self.topRightCorner) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber - 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles)
        ];

    } else if (minesTileSequenceNumber == self.bottomLeftCorner) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber + 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles + 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles)
        ];

    } else if (minesTileSequenceNumber ==
               self.topRightCorner + self.bottomLeftCorner) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber - 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles)
        ];

    }
    // Top horizontal Row
    else if (minesTileSequenceNumber < self.topRightCorner) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber - 1),
            @(minesTileSequenceNumber + 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles + 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles)
        ];

    }
    // Extreme right vertical row
    else if ((minesTileSequenceNumber + 1) % self.totalNumberOfRequiredTiles ==
             0) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber - 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles - 1)
        ];

    }
    // Extreme left vertical row
    else if (minesTileSequenceNumber % self.totalNumberOfRequiredTiles == 0) {

        resultantNeightbors = @[
            @(minesTileSequenceNumber + 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles + 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles + 1)
        ];

    }
    // Bottom horizontal row
    else if (minesTileSequenceNumber > self.bottomLeftCorner) {
        resultantNeightbors = @[
            @(minesTileSequenceNumber - 1),
            @(minesTileSequenceNumber + 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles + 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles)
        ];

    }
    // Any tile inside grid and not touching any adjacent boundary
    else {
        resultantNeightbors = @[
            @(minesTileSequenceNumber - 1),
            @(minesTileSequenceNumber + 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber + self.totalNumberOfRequiredTiles + 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles - 1),
            @(minesTileSequenceNumber - self.totalNumberOfRequiredTiles + 1)
        ];
    }

    NSLog(@"%d Tile Sequence number", minesTileSequenceNumber);

    for (NSString *individualNumber in resultantNeightbors) {
        if ([self.numberOfSurroundingMinesHolder
                objectForKey:individualNumber]) {
            NSInteger previousValueOfNeighboringMine =
                [self.numberOfSurroundingMinesHolder
                        [individualNumber] integerValue];
            previousValueOfNeighboringMine += 1;
            self.numberOfSurroundingMinesHolder[individualNumber] =
                @(previousValueOfNeighboringMine);
        } else {
            self.numberOfSurroundingMinesHolder[individualNumber] = @(1);
        }
    }
    NSLog(@"%@", self.numberOfSurroundingMinesHolder);
}

- (void)showAllMines {
    for (JKCustomButton *individualMinesButton in self.minesButtonsHolder) {
        [individualMinesButton setBackgroundColor:[UIColor blueColor]];
    }
}
@end
