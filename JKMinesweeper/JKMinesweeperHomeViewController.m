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
@property(weak, nonatomic) IBOutlet UIScrollView *superParentScrollView;

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
@property(assign, nonatomic) NSInteger currentScoreValue;
@property(weak, nonatomic) IBOutlet UILabel *currentScore;

@end

@implementation JKMinesweeperHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.levelNumberSelected = 1;
    self.currentScoreValue = 0;
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


    [self resetRevealMenuButton];
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

-(void)resetRevealMenuButton {
    self.revealMenuButton.tag = MINES_NOT_REVEALED_STATE;
    [self.revealMenuButton setTitle:@"Reveal" forState:UIControlStateNormal];
}

- (IBAction)verifyLossWinButtonPressed:(UIButton *)sender {


    BOOL didUserWinCurrentGame =
        (_totalNumberOfTilesRevealed ==
         (self.maximumTileSequence - self.totalNumberOfMinesOnGrid));
    NSString *currentGameStatusMessage = @"N/A";
    
    if(_totalNumberOfTilesRevealed > 0) {
        if (didUserWinCurrentGame) {
            currentGameStatusMessage = @"You won this game. Click the button "
            @"below to start a new game";
        } else {
            currentGameStatusMessage = @"Sorry, you still need to unleash few "
            @"tiles before we could declare you as " @"Winner";
        }
    }
    else {
        currentGameStatusMessage = @"You haven't started game yet. Please Start a new game verify the game state";
    }
    [self showAlertViewWithMessage:currentGameStatusMessage];
}

- (void)createNewGridOnScreen {

    [self resetRevealMenuButton];
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
        CGRectMake(startingXPositionForGridView - 20, 20, gridHeightAndWidth,
                   gridHeightAndWidth);

    [self.gridHolderView setBackgroundColor:[UIColor lightGrayColor]];
    NSInteger buttonSequenceNumber = 0;
    BOOL doesMineExistForTile = NO;
    NSInteger totalNumberOfMinesSurroundingGivenTile = 0;

    dispatch_time_t time = DISPATCH_TIME_NOW;
    NSInteger successiveTilesDistanceIncrement = DEFAULT_TILE_WIDTH + DEFAULT_GUTTER_WIDTH;
    
    for (NSInteger heightParamters = 0; heightParamters < gridHeightAndWidth;
         heightParamters += successiveTilesDistanceIncrement) {
        for (NSInteger widthParameter = 0; widthParameter < gridHeightAndWidth;
             widthParameter += successiveTilesDistanceIncrement) {

            buttonSequenceNumber =
                ((widthParameter / successiveTilesDistanceIncrement) +
                 (heightParamters / successiveTilesDistanceIncrement) * self.totalNumberOfRequiredTiles);

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

            newRevealMineButton.randomTileSelectedInstant =
                ^(NSInteger buttonSequenceNumber) {

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
                    animateWithDuration:REGULAR_ANIMATION_DURATION
                             animations:^{
                                 newRevealMineButton.alpha = 1.0;
                             }
                             completion:nil];
            });
            time = dispatch_time(time, MULTIPLE_ANIMATION_DURATION * NSEC_PER_SEC);
        }
    }

    CGFloat contentSizeWidth = self.superParentScrollView.frame.size.width;
    if (self.gridHolderView.frame.size.width >
        self.superParentScrollView.frame.size.width) {

        contentSizeWidth = self.gridHolderView.frame.size.width + 20;


        self.superParentScrollView.contentInset =
            UIEdgeInsetsMake(0, ((self.gridHolderView.frame.size.width -
                                  self.superParentScrollView.frame.size.width) /
                                 2) +
                                    20,
                             40, 0);
    }


    [self.superParentScrollView addSubview:self.gridHolderView];
    [self.superParentScrollView
        setContentSize:CGSizeMake(contentSizeWidth,
                                  self.gridHolderView.frame.size.height + 40)];
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


        [UIView animateWithDuration:REGULAR_ANIMATION_DURATION
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

            self.currentScoreValue += self.levelNumberSelected;
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

            self.currentScoreValue +=
                self.levelNumberSelected *
                buttonWithCurrentIdentifier.buttonStateModel
                    .numberOfNeighboringMines;
        }
        self.currentScore.text =
            [NSString stringWithFormat:@"%d", self.currentScoreValue];
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
    [self resetGridWithNewTilesAndCompletionBlock:^{
        [self createGridButtonPressed:nil];
    }];
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
    self.currentScoreValue = 0;
    self.currentScore.text = @"0";
    dispatch_time_t time = DISPATCH_TIME_NOW;

    NSArray *allButtonsInGridView = [self.gridHolderView subviews];
    for (UIView *individualButtonOnGrid in allButtonsInGridView) {

        dispatch_after(time, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:REGULAR_ANIMATION_DURATION
                animations:^{
                    individualButtonOnGrid.alpha = 0.0;
                }
                completion:^(BOOL finished) {
                    [individualButtonOnGrid removeFromSuperview];
                }];
        });
        time = dispatch_time(time, MULTIPLE_ANIMATION_DURATION * NSEC_PER_SEC);
    }
    if (resetTilesFinishedBlock) {
        resetTilesFinishedBlock();
    }
}

- (IBAction)revealMinesButtonPressed:(UIButton *)sender {

    if(self.minesButtonsHolder.count > 0) {
        if (sender.tag == MINES_NOT_REVEALED_STATE) {
            sender.tag = MINES_REVEALED_STATE;
            [self.revealMenuButton setTitle:@"Hide" forState:UIControlStateNormal];
            for (
                 JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
                individualTileWithMine.backgroundColor = [UIColor greenColor];
            }
        } else {
            sender.tag = MINES_NOT_REVEALED_STATE;
            [self.revealMenuButton setTitle:@"Reveal"
                               forState:UIControlStateNormal];
            for (
                 JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
                individualTileWithMine.backgroundColor = [UIColor orangeColor];
            }
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
            [UIView animateWithDuration:REGULAR_ANIMATION_DURATION
                animations:^{
                    [individualMinesButton
                        setBackgroundColor:[UIColor blueColor]];
                }
                completion:^(BOOL finished) {
                    individualMinesButton.buttonStateModel
                        .tileSelectedIndicator = YES;
                }];
        });
        time = dispatch_time(time, REGULAR_ANIMATION_DURATION * NSEC_PER_SEC);
    }
}

- (IBAction)levelNumberButtonPressed:(id)sender {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        //older than iOS 8 code here
        UIActionSheet *popup = [[UIActionSheet alloc]
                                initWithTitle:SELECT_LEVEL_TITLE
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Easy", @"Medium", @"Difficult", @"Expert", nil];
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        //iOS 8 specific code here
        [self showiOS8ActionSheet];
    }
}

- (void)actionSheet:(UIActionSheet *)popup
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 4) {
        [self setViewForSelectedLevelWithNumber:buttonIndex + 1];
    }
}

-(void)setViewForSelectedLevelWithNumber:(NSInteger)levelNumber {
    self.levelNumberSelected = levelNumber;
    [self.levelNumberButton
     setTitle:[NSString
               stringWithFormat:@"Level %d", self.levelNumberSelected]
     forState:UIControlStateNormal];
}

- (void)showiOS8ActionSheet {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SELECT_LEVEL_TITLE
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *easyLevel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Easy", @"Easy action")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                  {
                                      [self setViewForSelectedLevelWithNumber:1];
                                  }];
    
    UIAlertAction *mediumLevel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Medium", @"Medium action")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                  {
                                      [self setViewForSelectedLevelWithNumber:2];
                                  }];
    
    UIAlertAction *difficultLevel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Difficult", @"Difficult action")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [self setViewForSelectedLevelWithNumber:3];
                                       
                                   }];
    UIAlertAction *expertLevel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Expert", @"Expert action")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [self setViewForSelectedLevelWithNumber:4];
                                       
                                   }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"Cancel Button Pressed");
                                        
                                    }];
    
    [alertController addAction:easyLevel];
    [alertController addAction:mediumLevel];
    [alertController addAction:difficultLevel];
    [alertController addAction:expertLevel];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
