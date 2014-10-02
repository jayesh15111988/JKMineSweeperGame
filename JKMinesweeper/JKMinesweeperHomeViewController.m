//
//  JKMinesweeperHomeViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import "JKMinesweeperHomeViewController.h"
#import "JKNeighbouringTilesProvider.h"
#import "JKMineSweeperConstants.h"
#import "JKCustomButton.h"
#import "JKButtonStateModel.h"

typedef void (^resetTilesFinishedBlock)();

@interface JKMinesweeperHomeViewController () <UIAlertViewDelegate,
                                               UIActionSheetDelegate>

@property(weak, nonatomic) IBOutlet UITextField *gridSizeInputText;
@property(weak, nonatomic) IBOutlet UIButton *createGridButton;
@property(strong, nonatomic) UIView *gridHolderView;
@property(strong, nonatomic) NSMutableDictionary *minesLocationHolder;
@property(assign, nonatomic) NSInteger totalNumberOfMinesOnGrid;

@property(strong, nonatomic) NSMutableArray *minesButtonsHolder;
@property(strong, nonatomic) NSMutableArray *regularButtonsHolder;

@property(assign, nonatomic) NSInteger totalNumberOfRequiredTiles;
@property(strong, nonatomic)
    NSMutableDictionary *numberOfSurroundingMinesHolder;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)revealMinesButtonPressed:(id)sender;
@property(weak, nonatomic) IBOutlet UIButton *revealMenuButton;
@property(weak, nonatomic) IBOutlet UIButton *resetButton;

@property(assign, nonatomic) NSInteger topRightCorner;
@property(assign, nonatomic) NSInteger bottomLeftCorner;

@property(weak, nonatomic) IBOutlet UIButton *verifyLossWinButton;
@property(assign, nonatomic) NSInteger totalNumberOfTilesRevealed;
@property(assign, nonatomic) NSInteger maximumTileSequence;
@property(weak, nonatomic) IBOutlet UIButton *levelNumberButton;

@property(assign, nonatomic) NSInteger levelNumberSelected;

@end

@implementation JKMinesweeperHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.levelNumberSelected = 1;
    self.gridHolderView = [[UIView alloc] init];
    self.minesLocationHolder = [NSMutableDictionary new];
    self.minesButtonsHolder = [NSMutableArray new];
    self.regularButtonsHolder = [NSMutableArray new];
    self.numberOfSurroundingMinesHolder = [NSMutableDictionary new];
    self.totalNumberOfTilesRevealed = 0;
    [self.createGridButton addTarget:self
                              action:@selector(createGridButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];

    [self.verifyLossWinButton addTarget:self
                                 action:@selector(verifyLossWinButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];

    [self.levelNumberButton addTarget:self
                               action:@selector(levelNumberButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)createGridButtonPressed:(UIButton *)sender {


    self.revealMenuButton.tag = 14;
    [self.revealMenuButton setTitle:@"Reveal" forState:UIControlStateNormal];
    self.totalNumberOfRequiredTiles =
        [self.gridSizeInputText.text integerValue];

    if (self.totalNumberOfRequiredTiles < 3) {
        self.totalNumberOfRequiredTiles = 3;
    }

    // We are setting number of mines equal to number of tiles in a single row
    self.totalNumberOfMinesOnGrid =
        self.totalNumberOfRequiredTiles * self.levelNumberSelected;

    [self createNewGridOnScreen];
}

- (IBAction)verifyLossWinButtonPressed:(UIButton *)sender {


    BOOL didUserWinCurrentGame =
        (self.totalNumberOfTilesRevealed ==
         (self.maximumTileSequence - self.totalNumberOfMinesOnGrid));

    NSString *currentGameStatusMessage = @"N/A";

    if (didUserWinCurrentGame) {
        currentGameStatusMessage = @"You won this game. Click the button "
            @"below to start a new game";
    } else {
        currentGameStatusMessage = @"Sorry, you still need to unleash few "
            @"tiles before we could declare you as " @"Winner";
    }

    [self showAlertViewWithMessage:currentGameStatusMessage];
}

- (void)createNewGridOnScreen {


    [self resetGridWithNewTilesAndCompletionBlock:nil];


    self.createGridButton.enabled = NO;
    self.resetButton.enabled = YES;
    self.revealMenuButton.enabled = YES;


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

    dispatch_time_t time = DISPATCH_TIME_NOW;

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

            newRevealMineButton.buttonStateModel.sequenceOfNeighbouringTiles =
                [JKNeighbouringTilesProvider
                    getNeighbouringTilesForGivenTileWithSequence:
                        buttonSequenceNumber
                                       andTotalTilesInSingleLine:
                                           self.totalNumberOfRequiredTiles];

            __weak typeof(self) weakSelf = self;

            newRevealMineButton.gameOverInstant = ^() {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf showAllMines];
                [strongSelf showAlertViewWithMessage:@"You clicked on mine and "
                            @"game is now over"];
            };

            //            __weak typeof(JKCustomButton*) weakButtonObject =
            //            newRevealMineButton;

            newRevealMineButton.randomTileSelectedInstant =
                ^(NSInteger buttonSequenceNumber) {
                //              __strong __typeof(JKCustomButton*)
                //              strongButtonObject = weakButtonObject;
                __strong __typeof(weakSelf) strongSelf = weakSelf;

                [strongSelf highlightNeighbouringButtonsForButtonSequence:
                                buttonSequenceNumber];
            };


            if (doesMineExistForTile) {
                [self.minesButtonsHolder addObject:newRevealMineButton];
            } else {
                [self.regularButtonsHolder addObject:newRevealMineButton];
            }
            [self.gridHolderView addSubview:newRevealMineButton];
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [UIView
                    animateWithDuration:0.2
                             animations:^{ newRevealMineButton.alpha = 1.0; }
                             completion:nil];
            });
            time = dispatch_time(time, 0.04 * NSEC_PER_SEC);
        }
    }

    [self.view addSubview:self.gridHolderView];
}

- (JKCustomButton *)getButtonWithSequence:(NSInteger)buttonSequence {
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"buttonSequenceNumber == %d", buttonSequence];
    return [[self.regularButtonsHolder
        filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)highlightNeighbouringButtonsForButtonSequence:
            (NSInteger)buttonSequence {


    JKCustomButton *buttonWithCurrentIdentifier =
        [self getButtonWithSequence:buttonSequence];

    if (!buttonWithCurrentIdentifier.isVisited) {


        [UIView animateWithDuration:0.5
                         animations:^{
                             [buttonWithCurrentIdentifier
                                 setBackgroundColor:[UIColor redColor]];
                         }
                         completion:nil];

        self.totalNumberOfTilesRevealed++;

        buttonWithCurrentIdentifier.isVisited = YES;
        buttonWithCurrentIdentifier.buttonStateModel.tileSelectedIndicator =
            buttonWithCurrentIdentifier.isVisited;

        if ((buttonWithCurrentIdentifier.buttonStateModel
                 .numberOfNeighboringMines == 0)) {
            NSArray *collectionOfSurroundingTilesForCurrentTile =
                buttonWithCurrentIdentifier.buttonStateModel
                    .sequenceOfNeighbouringTiles;

            for (NSString *storedNeighboringTilesSequence in
                     collectionOfSurroundingTilesForCurrentTile) {
                NSInteger tileSequenceIdentifier =
                    [storedNeighboringTilesSequence integerValue];
                [self highlightNeighbouringButtonsForButtonSequence:
                          tileSequenceIdentifier];
            }
        } else {
            [buttonWithCurrentIdentifier
                setTitle:[NSString
                             stringWithFormat:@"%d",
                                              buttonWithCurrentIdentifier
                                                  .buttonStateModel
                                                  .numberOfNeighboringMines]
                forState:UIControlStateNormal];
        }
    }
}

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *gameOverAlertView =
        [[UIAlertView alloc] initWithTitle:@"Minesweeper"
                                   message:message
                                  delegate:self
                         cancelButtonTitle:@"Start new game"
                         otherButtonTitles:@"Continue", nil];
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

    self.maximumTileSequence = pow(maximumNumberOfTilesInRow, 2);

    NSInteger minesGeneratedSoFar = 0;
    NSInteger generateRandomMinesSequence = 0;


    // Variables to hold specific corners of box
    self.topRightCorner = maximumNumberOfTilesInRow - 1;
    self.bottomLeftCorner = (maximumNumberOfTilesInRow)*self.topRightCorner;


    while (minesGeneratedSoFar < self.totalNumberOfMinesOnGrid) {

        generateRandomMinesSequence =
            [self getRandomNumberWithMinValue:0
                                  andMaxValue:self.maximumTileSequence];
        if (![self.minesLocationHolder
                objectForKey:@(generateRandomMinesSequence)]) {
            minesGeneratedSoFar++;
            [self getNeighboringValidCellsForGivenMineWithSequence:
                      generateRandomMinesSequence];

            [self.minesLocationHolder setObject:@"1"
                                         forKey:@(generateRandomMinesSequence)];
        }
    }
}

- (NSInteger)getRandomNumberWithMinValue:(NSInteger)minValue
                             andMaxValue:(NSInteger)maxValue {
    return arc4random() % (maxValue - minValue) + minValue;
}

- (IBAction)resetButtonPressed:(UIButton *)sender {
    [self resetGridWithNewTilesAndCompletionBlock:nil];
}

- (void)resetGridWithNewTilesAndCompletionBlock:
            (void (^)())resetTilesFinishedBlock {

    self.createGridButton.enabled = YES;
    self.resetButton.enabled = NO;
    self.revealMenuButton.enabled = NO;

    [self.minesLocationHolder removeAllObjects];
    [self.regularButtonsHolder removeAllObjects];
    [self.minesButtonsHolder removeAllObjects];
    [self.numberOfSurroundingMinesHolder removeAllObjects];
    self.totalNumberOfTilesRevealed = 0;

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
    if (resetTilesFinishedBlock) {
        resetTilesFinishedBlock();
    }
}

- (IBAction)revealMinesButtonPressed:(UIButton *)sender {

    if (sender.tag == 14) {
        sender.tag = 15;
        [self.revealMenuButton setTitle:@"Hide" forState:UIControlStateNormal];
        for (
            JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
            individualTileWithMine.backgroundColor = [UIColor greenColor];
        }
    } else {
        sender.tag = 14;
        [self.revealMenuButton setTitle:@"Reveal"
                               forState:UIControlStateNormal];
        for (
            JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
            individualTileWithMine.backgroundColor = [UIColor orangeColor];
        }
    }
}

- (void)getNeighboringValidCellsForGivenMineWithSequence:
            (NSInteger)minesTileSequenceNumber {

    NSArray *resultantNeightbors = [JKNeighbouringTilesProvider
        getNeighbouringTilesForGivenTileWithSequence:minesTileSequenceNumber
                           andTotalTilesInSingleLine:
                               self.totalNumberOfRequiredTiles];


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
}

- (void)showAllMines {

    dispatch_time_t time = DISPATCH_TIME_NOW;

    for (JKCustomButton *individualMinesButton in self.minesButtonsHolder) {

        dispatch_after(time, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3
                animations:^{
                    [individualMinesButton
                        setBackgroundColor:[UIColor blueColor]];
                }
                completion:^(BOOL finished) {
                    individualMinesButton.buttonStateModel
                        .tileSelectedIndicator = YES;
                }];
        });
        time = dispatch_time(time, 0.3 * NSEC_PER_SEC);
    }
}

- (IBAction)levelNumberButtonPressed:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc]
                 initWithTitle:@"Select Target Level"
                      delegate:self
             cancelButtonTitle:@"Cancel"
        destructiveButtonTitle:nil
             otherButtonTitles:@"Easy", @"Medium", @"Difficult", nil];
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 3) {
        self.levelNumberSelected = buttonIndex + 1;
        [self.levelNumberButton
            setTitle:[NSString
                         stringWithFormat:@"Level %d", self.levelNumberSelected]
            forState:UIControlStateNormal];
    }
}
@end
