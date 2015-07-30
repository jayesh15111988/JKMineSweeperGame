//
//  JKMinesweeperHomeViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <HRColorPickerView.h>
#import <FLAnimatedImage.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+MJPopupViewController.h"
#import <Realm.h>
#import <RLMResults.h>
#import <UIAlertView+BlocksKit.h>
#import <NSArray+BlocksKit.h>
#import <KLCPopup.h>

#import "SaveGameModel.h"
#import "JKAudioOperations.h"
#import "JKRandomStringGenerator.h"
#import "JKMinesweeperHomeViewController.h"
#import "JKNeighbouringTilesProvider.h"
#import "JKMineSweeperConstants.h"
#import "JKCustomButton.h"
#import "UIButton+Utility.h"
#import "JKButtonStateModel.h"
#import "JKMinesweeperSavedGamesViewController.h"
#import "ScoreSaver.h"
#import "JKMinesweeperScoresViewController.h"
#import "JKMinesweeperSettingsViewController.h"
#import "JKTimerProviderUtility.h"

typedef void (^resetTilesFinishedBlock)();

@interface JKMinesweeperHomeViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property(weak, nonatomic) IBOutlet UITextField *gridSizeInputText;
@property(strong, nonatomic) UIView *gridHolderView;
@property(strong, nonatomic) NSMutableDictionary *minesLocationHolder;
@property(assign, nonatomic) NSInteger totalNumberOfMinesOnGrid;
@property(weak, nonatomic) IBOutlet UIScrollView *superParentScrollView;
@property (strong, nonatomic) UIView* currentViewForColorpicker;
@property (strong, nonatomic) NSString* currentGameIdentifier;
@property (strong, nonatomic) FLAnimatedImage *animatedExplosionImage;

@property (strong, nonatomic) HRColorPickerView* colorPickerView;
@property (assign, nonatomic) CurrentGameState gameState;
@property (assign, nonatomic) SoundCategory soundCategory;
@property (assign, nonatomic) GameState gameStateNewLoaded;

@property (strong, nonatomic) UIView* bottomViewForColorPicker;
@property (strong, nonatomic) UIButton* changeGridBakcgroundColorButton;

@property(strong, nonatomic) NSMutableArray *minesButtonsHolder;
@property(strong, nonatomic) NSMutableArray *regularButtonsHolder;

@property(assign, nonatomic) NSInteger totalNumberOfRequiredTiles;
@property(strong, nonatomic) NSMutableDictionary *numberOfSurroundingMinesHolder;
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

@property(assign, nonatomic) NSInteger tileWidth;
@property(assign, nonatomic) NSInteger gutterSpacing;
@property(assign, nonatomic) BOOL toPlaySound;

@property (strong, nonatomic) JKMinesweeperScoresViewController* pastScoresViewController;
@property (strong, nonatomic) JKMinesweeperSettingsViewController* settingsViewController;
@property (strong, nonatomic) JKAudioOperations* audioOperationsManager;
@property (strong, nonatomic) JKMinesweeperSavedGamesViewController* savedGamesViewController;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *timerIndicatorButton;

@property (strong, nonatomic) JKTimerProviderUtility* timerProviderUtility;
@property (strong, nonatomic) KLCPopup* popupView;

@end

@implementation JKMinesweeperHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioOperationsManager = [[JKAudioOperations alloc] init];
    [self setupUIFromUserDefaultParameters];
    self.currentScoreValue = 0;
    self.gridHolderView = [[UIView alloc] init];
    self.minesLocationHolder = [NSMutableDictionary new];
    self.minesButtonsHolder = [NSMutableArray new];
    self.regularButtonsHolder = [NSMutableArray new];
    self.numberOfSurroundingMinesHolder = [NSMutableDictionary new];
    self.totalNumberOfTilesRevealed = 0;
    [self.levelNumberButton setTitle:[NSString stringWithFormat:@"Level %ld", (long)self.levelNumberSelected] forState:UIControlStateNormal];

    [self.verifyLossWinButton addTarget:self
                                 action:@selector(verifyLossWinButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];

    [self.levelNumberButton addTarget:self
                               action:@selector(levelNumberButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self setupRACSignalsAndNotifications];
    
    [self playGameStartSound];
    [self createNewGridWithParameters];
}

-(void)setupRACSignalsAndNotifications {
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPresentedViewController) name:HIDE_POPOVER_VIEW_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNewTimeValue) name:TIMER_VALUE_CHANGED object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSounds) name:SOUND_SETTINGS_CHANGED object:nil];
    
    [RACObserve(self, levelNumberSelected) subscribeNext:^(NSNumber *newLevelnumber) {
        [[NSUserDefaults standardUserDefaults] setObject:newLevelnumber forKey:@"currentLevel"];
        [self.levelNumberButton
         setTitle:[NSString
                   stringWithFormat:@"Level %@", newLevelnumber]
         forState:UIControlStateNormal];
    }];
    
    
    [RACObserve(self, totalNumberOfTilesRevealed) subscribeNext:^(NSNumber *numberOfTilesUnleashed) {
        if([numberOfTilesUnleashed integerValue] > 0) {
            self.gameState = InProgress;
        }
    }];
    
    [RACObserve(self, gameState) subscribeNext:^(NSNumber *currentGameState) {
        self.saveButton.hidden = (self.gameState != InProgress);
        [self updateUIWithNewTimeValue];
    }];
    
    
    self.saveButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(UIButton* _) {
        
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        
        
        UIAlertView *saveGameScoreDialogue =
        [[UIAlertView alloc] initWithTitle:@"Save Game"
                                   message:@"Please type your name this game"
                                  delegate:self
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:@"Ok", nil];
        saveGameScoreDialogue.tag = 15;
        saveGameScoreDialogue.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[saveGameScoreDialogue textFieldAtIndex:0] setText:[formatter stringFromDate:[NSDate date]]];
        
        [saveGameScoreDialogue show];
        return [RACSignal empty];
    }];

    
    self.loadButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(UIButton* _) {
        DLog(@"Load Button was pressed!");
        if(!self.savedGamesViewController) {
            self.savedGamesViewController = [[JKMinesweeperSavedGamesViewController alloc] initWithNibName:@"JKMinesweeperSavedGamesViewController" bundle:nil];
              __weak typeof(self) weakSelf = self;
            self.savedGamesViewController.openSelectedGameModel = ^(SaveGameModel* selectedGameModel) {
                
                __strong typeof(self) strongSelf = weakSelf;
                
                [strongSelf resetGameBeforeLoadingPreviousGame:selectedGameModel];
                [strongSelf dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideRightRight];
                
                //Now load all tiles on the front page
                NSArray *allCustomButtonCollection=[NSKeyedUnarchiver unarchiveObjectWithData:selectedGameModel.savedGameData];
                
                NSArray* collectionWithSelectedTiles = [allCustomButtonCollection bk_select:^BOOL(JKCustomButton* currentButtonObject) {
                    TileStateRepresentationValue currentButtonState = currentButtonObject.buttonStateModel.currentTileState;
                    return (currentButtonState == TileIsSelected || currentButtonState == TileIsQuestionMarked);
                }];
                
                DLog(@"%ld and %ld", (long)strongSelf.regularButtonsHolder.count, (long)strongSelf.minesButtonsHolder.count);
                
                strongSelf.totalNumberOfTilesRevealed = [collectionWithSelectedTiles count];
                
                for(JKCustomButton* individualButton in allCustomButtonCollection) {
                    DLog(@"In button mine %ld Sequence number %ld current tile state %ld ", (long)individualButton.buttonStateModel.isThisButtonMine, (long)individualButton.buttonSequenceNumber, (long)individualButton.buttonStateModel.currentTileState);
                    individualButton.frame = CGRectMake(individualButton.positionOnScreen.x, individualButton.positionOnScreen.y, strongSelf.tileWidth, strongSelf.tileWidth);
                    
                    [individualButton configurePreviousButton:individualButton.positionOnScreen andWidth:strongSelf.tileWidth andButtonState:individualButton.buttonStateModel];
                    

                    if(individualButton.buttonStateModel.isThisButtonMine) {
                        [strongSelf.minesButtonsHolder addObject:individualButton];
                    }
                    else {
                        [strongSelf.regularButtonsHolder addObject:individualButton];
                    }
                    
                    //For each button retrieved from database, we will add long press gesture to it
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:strongSelf action:@selector(longPress:)];
                    [individualButton addGestureRecognizer:longPress];
                    
                    individualButton.gameOverInstant = ^() {
                        [strongSelf showAllMines];
                        strongSelf.gameState = OverAndLoss;
                        [strongSelf showAlertViewWithMessage:@"You clicked on mine and "
                         @"game is now over"];
                        [strongSelf playGameOverSound];
                        
                    };
                    
                    individualButton.randomTileSelectedInstant =
                    ^(NSInteger buttonSequenceNumber) {
                        
                        if(![strongSelf isGameOver]) {
                            [strongSelf highlightNeighbouringButtonsForButtonSequence: buttonSequenceNumber];
                        }
                    };
                    [strongSelf.gridHolderView addSubview:individualButton];
                }
                
                 DLog(@"%ld and %ld %ld", (long)strongSelf.regularButtonsHolder.count, (long)strongSelf.minesButtonsHolder.count,(long)strongSelf.gridHolderView.subviews.count);
            };
        }
        
        
        [self showInPopupWithView:self.savedGamesViewController.view];
        return [RACSignal empty];
    }];
    
    self.timerIndicatorButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(UIButton* _) {
        DLog(@"Timer Button Pressed");
        
        if(self.timerProviderUtility.currentTimerState == TimerIsPlaying) {
            [self.audioOperationsManager stopBackgroundMusic];
            [self.timerProviderUtility pauseTimer];
        }
        else {
            [self.timerProviderUtility startTimer];
        }
        return [RACSignal empty];
    }];
}

- (void)showInPopupWithView:(UIView*)inputPopupView {
    self.popupView = [KLCPopup popupWithContentView:inputPopupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToTop maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    inputPopupView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    [self.popupView show];
}

-(void)resetGameBeforeLoadingPreviousGame:(SaveGameModel*)selectedGameModel {
    
    //Unreveal all tiles if they are revealed in the previous game
    if(self.revealMenuButton.tag == MINES_REVEALED_STATE) {
        [self resetRevealMenuButton];
    }
    
    self.gameStateNewLoaded = SavedGame;
    self.currentScoreValue = selectedGameModel.score;
    self.currentScore.text = [NSString stringWithFormat:@"%ld",(long)self.currentScoreValue];
    DLog(@"current score is %ld", (long)selectedGameModel.score);
    [self.levelNumberButton setTitle:[NSString stringWithFormat:@"Level %ld",(long)(selectedGameModel.levelNumber)] forState:UIControlStateNormal];
    self.levelNumberSelected = selectedGameModel.levelNumber;
    self.gridSizeInputText.text = selectedGameModel.numberOfTilesInRow;
         
    self.totalNumberOfRequiredTiles = [self.gridSizeInputText.text integerValue];
    
    //Setup Grid size to match the one number of tiles here
    
    [self setupGridHolderView];
    
    if (self.totalNumberOfRequiredTiles < 3) {
        self.totalNumberOfRequiredTiles = 3;
    }
    //We will use previous identifier and will use to overwrite existing game
    self.currentGameIdentifier = selectedGameModel.identifier;//[JKRandomStringGenerator generateRandomStringWithLength:6];
    NSArray *allButtonsInGridView = [self.gridHolderView subviews];
    for (UIView *individualButtonOnGrid in allButtonsInGridView) {
        [individualButtonOnGrid removeFromSuperview];
    }
    [self.regularButtonsHolder removeAllObjects];
    [self.minesButtonsHolder removeAllObjects];
}

-(void)updateSounds {
    BOOL isSoundEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
    
    if(isSoundEnabled) {
        [self playBackgroundSound];
    }
    else {
        [self.audioOperationsManager stopBackgroundMusic];
    }
}

-(void)dismissPresentedViewController {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    [self.popupView dismiss:YES];
}

-(void)updateUIWithNewTimeValue {
    self.timerIndicatorButton.hidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"timer"] boolValue];
    if(!self.timerIndicatorButton.hidden) {
        if(self.gameState == InProgress) {
            if(self.timerProviderUtility.currentTimerState != TimerIsPaused) {
                if(!self.timerProviderUtility) {
                    self.timerProviderUtility = [[JKTimerProviderUtility alloc] init];
                    __weak typeof(self) weakSelf = self;
                    self.timerProviderUtility.UpdateTimerLabelBlock = ^(NSString* updatedTimerLabelValue) {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf.timerIndicatorButton setTitle:updatedTimerLabelValue forState:UIControlStateNormal];
                    };
                }
                [self.timerProviderUtility startTimer];
            }
        }
        else {
            [self.timerProviderUtility resetTimer];
        }
    }
}

-(BOOL)isGameOver {
    return (self.gameState == OverAndWin || self.gameState == OverAndLoss);
}

-(void)setupUIFromUserDefaultParameters {
    self.levelNumberSelected = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentLevel"] integerValue];
    self.tileWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tileWidth"] integerValue];
    self.gutterSpacing = [[[NSUserDefaults standardUserDefaults] objectForKey:@"gutterSpacing"] integerValue];
    self.toPlaySound = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
    [self updateUIWithNewTimeValue];
}

- (void)createNewGridWithParameters {

    self.gameState = NotStarted;
    self.gameStateNewLoaded = NewGame;
    
    [self setupUIFromUserDefaultParameters];
    [self resetRevealMenuButton];
    self.totalNumberOfRequiredTiles =
        [self.gridSizeInputText.text integerValue];

    if (self.totalNumberOfRequiredTiles < 3) {
        self.totalNumberOfRequiredTiles = 3;
    }

    self.currentGameIdentifier = [JKRandomStringGenerator generateRandomStringWithLength:6];
    
    // We are setting number of mines equal to number of tiles in a single row
    self.totalNumberOfMinesOnGrid =
        self.totalNumberOfRequiredTiles * self.levelNumberSelected;

    [self createNewGridOnScreen];
    [self playBackgroundSound];
}

-(void)resetRevealMenuButton {
    self.revealMenuButton.tag = MINES_NOT_REVEALED_STATE;
    [self.revealMenuButton setTitle:@"Reveal" forState:UIControlStateNormal];
    [self.timerIndicatorButton setTitle:@"00 : 00" forState:UIControlStateNormal];
    [self.audioOperationsManager stopBackgroundMusic];
}

- (IBAction)verifyLossWinButtonPressed:(UIButton *)sender {

    //We are prechecking if user has won this game after checking status for each tile revealed. Sender is nil if user has already won this game. If button has manual entry, then user is probably still in the game
    
    BOOL didUserWinCurrentGame = (sender == nil);
    
    NSString *currentGameStatusMessage = @"N/A";
    
    if(self.gameState != NotStarted) {
        if (didUserWinCurrentGame) {
            [self.audioOperationsManager playForegroundSoundFXnamed:@"gamewin.wav" loop:NO];
            [self.audioOperationsManager stopBackgroundMusic];
            self.gameState = OverAndWin;
            currentGameStatusMessage = @"You won this game. Click the button "
            @"below to start a new game";
        } else {
            if(self.gameState != OverAndLoss) {
                currentGameStatusMessage = @"Sorry, you still need to unleash few "
                @"tiles before we could declare you as " @"Winner";
            }
            else {
                currentGameStatusMessage =@"Sorry you have lost in this game. Please click reset button to generate new game";
            }
        }
    }
    else {
        currentGameStatusMessage = @"You haven't started game yet. Please Start a new game verify the game state";
    }
    [self showAlertViewWithMessage:currentGameStatusMessage];
}

-(BOOL)didWinUserCurrentGameLiveCheck {
    return  (_totalNumberOfTilesRevealed == (self.maximumTileSequence - self.totalNumberOfMinesOnGrid));
}


-(NSInteger)setupGridHolderView {
    
    NSInteger gridHeightAndWidth =
    (self.tileWidth * self.totalNumberOfRequiredTiles) +
    (self.gutterSpacing * (self.totalNumberOfRequiredTiles - 1));
    CGFloat startingXPositionForGridView =
    self.view.center.x - (gridHeightAndWidth / 2);
    DLog(@"%@", NSStringFromCGRect(self.view.frame));
    self.gridHolderView.frame =
    CGRectMake(self.view.center.y - gridHeightAndWidth/2,20, gridHeightAndWidth,
               gridHeightAndWidth);
    //self.gridHolderView.center = CGPointMake(self.view.center.y, self.view.center.x);

    [self setPositionOfChangeBackgroundColorButton];
    return gridHeightAndWidth;
}

- (void)createNewGridOnScreen {

    [self resetGridWithNewTilesAndCompletionBlock:nil];
    self.resetButton.enabled = YES;
    self.revealMenuButton.enabled = YES;


    [self populateMinesHolderWithMinesLocationsWithMaximumGridWidth:
              self.totalNumberOfRequiredTiles];
    
    NSInteger gridHeightAndWidth = [self setupGridHolderView];
    
    [self.gridHolderView setBackgroundColor:[UIColor lightGrayColor]];
    
    
    NSInteger buttonSequenceNumber = 0;
    BOOL doesMineExistForTile = NO;
    NSInteger totalNumberOfMinesSurroundingGivenTile = 0;

    dispatch_time_t time = DISPATCH_TIME_NOW;
    NSInteger successiveTilesDistanceIncrement = self.tileWidth + self.gutterSpacing;
    
    for (NSInteger yPosition = 0; yPosition < gridHeightAndWidth; yPosition += successiveTilesDistanceIncrement) {
        for (NSInteger xPosition = 0; xPosition < gridHeightAndWidth; xPosition += successiveTilesDistanceIncrement) {

            buttonSequenceNumber =
                ((xPosition / successiveTilesDistanceIncrement) +
                 (yPosition / successiveTilesDistanceIncrement) * self.totalNumberOfRequiredTiles);

            doesMineExistForTile =
                self.minesLocationHolder[@(buttonSequenceNumber)] ? YES : NO;

            totalNumberOfMinesSurroundingGivenTile =
                [self.numberOfSurroundingMinesHolder[
                    @(buttonSequenceNumber)] integerValue];

            JKCustomButton *newRevealMineButton = [[JKCustomButton alloc]
                           initWithPosition:CGPointMake(xPosition, yPosition)
                                   andWidth:self.tileWidth
                                  andIsMine:doesMineExistForTile
                    andButtonSequenceNumber:buttonSequenceNumber
                andNumberOfSurroundingMines:
                    totalNumberOfMinesSurroundingGivenTile];

            newRevealMineButton.buttonStateModel.sequenceOfNeighbouringTiles =
                [JKNeighbouringTilesProvider
                    getNeighbouringTilesForGivenTileWithSequence: buttonSequenceNumber
                                       andTotalTilesInSingleLine: self.totalNumberOfRequiredTiles];

            __weak typeof(self) weakSelf = self;

            newRevealMineButton.gameOverInstant = ^() {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf showAllMines];
                strongSelf.gameState = OverAndLoss;
                [strongSelf showAlertViewWithMessage:@"You clicked on mine and "
                            @"game is now over"];
                
                [strongSelf playGameOverSound];
                
            };

            newRevealMineButton.randomTileSelectedInstant =
                ^(NSInteger buttonSequenceNumber) {
                   
                    if(![self isGameOver]) {
                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf highlightNeighbouringButtonsForButtonSequence: buttonSequenceNumber];
                    }
            };


            if (doesMineExistForTile) {
                [self.minesButtonsHolder addObject:newRevealMineButton];
            } else {
                [self.regularButtonsHolder addObject:newRevealMineButton];
            }
            
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [newRevealMineButton addGestureRecognizer:longPress];
            
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
                                 2) + 20, 40, 0);
    }
    
    [self.superParentScrollView addSubview:self.gridHolderView];
    [self.superParentScrollView
        setContentSize:CGSizeMake(contentSizeWidth,
                                  self.gridHolderView.frame.size.height + 40)];
}

-(void)playGameOverSound {
    [self.audioOperationsManager stopBackgroundMusic];
    [self.audioOperationsManager playForegroundSoundFXnamed:@"explosion.wav"  loop:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.audioOperationsManager playForegroundSoundFXnamed:@"nuclearexplosion.wav" loop:NO];
    });
}

-(void)playBackgroundSound {
        [self.audioOperationsManager playBackgroundSoundFXnamed:@"background.wav" loop:YES];
}

-(void)playGameStartSound {
    [self.audioOperationsManager playBackgroundSoundFXnamed:@"start.wav" loop:NO];
}

-(void)playQuestionMarkSound {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"question.wav" loop:NO];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        
        JKCustomButton* longPressedButton = (JKCustomButton*)gesture.view;
        
        //Tile is already revealed, do not bother to decorate it with question mark
        if(longPressedButton.buttonStateModel.currentTileState == TileIsSelected) {
            return;
        }
        
        if(longPressedButton.buttonStateModel.currentTileState == TileIsQuestionMarked) {
            longPressedButton.buttonStateModel.currentTileState = TileIsNotSelected;
        }
        else {
            longPressedButton.buttonStateModel.currentTileState = TileIsQuestionMarked;
        }
        
        if(longPressedButton.buttonStateModel.currentTileState == TileIsQuestionMarked) {
            [longPressedButton setTitle:@"?" forState:UIControlStateNormal];
            [longPressedButton setBackgroundColor:[UIColor whiteColor]];
        }
        else {
            [longPressedButton setTitle:@"" forState:UIControlStateNormal];
            [longPressedButton setBackgroundColor:[UIColor orangeColor]];
        }
        [self playQuestionMarkSound];
    }
}

-(void)setPositionOfChangeBackgroundColorButton {
    CGRect changeGridColorButtonUpdatedFrame = CGRectMake(self.gridHolderView.frame.size.width + self.gridHolderView.frame.origin.x + 10, self.gridHolderView.frame.origin.y, 30, 30);
    
    if(!self.changeGridBakcgroundColorButton) {
        self.changeGridBakcgroundColorButton = [[UIButton alloc] initWithFrame:changeGridColorButtonUpdatedFrame];
        [self.changeGridBakcgroundColorButton setBackgroundImage:[UIImage imageNamed:@"changeColor"] forState:UIControlStateNormal];
        [self.changeGridBakcgroundColorButton addTarget:self action:@selector(changeGridBackgroundColorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.superParentScrollView addSubview:self.changeGridBakcgroundColorButton];
    }
    else {
        self.changeGridBakcgroundColorButton.frame = changeGridColorButtonUpdatedFrame;
    }
    
}

- (JKCustomButton *)getButtonWithSequence:(NSInteger)buttonSequence {
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"buttonSequenceNumber == %d", buttonSequence];
    return [[self.regularButtonsHolder
        filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)highlightNeighbouringButtonsForButtonSequence:
            (NSInteger)buttonSequence {

    [self.audioOperationsManager playForegroundSoundFXnamed:@"tilereveal.wav" loop:NO];
    
    JKCustomButton *buttonWithCurrentIdentifier =
        [self getButtonWithSequence:buttonSequence];

    if (!buttonWithCurrentIdentifier.isVisited) {

        [UIView animateWithDuration:REGULAR_ANIMATION_DURATION
                         animations:^{
                             [buttonWithCurrentIdentifier
                                 addDecorationWithImage:[UIImage imageNamed:@"normal"] orColor:[UIColor redColor]];
                         }
                         completion:nil];

        self.totalNumberOfTilesRevealed++;
        buttonWithCurrentIdentifier.isVisited = YES;
        buttonWithCurrentIdentifier.buttonStateModel.currentTileState =
            TileIsSelected;
        DLog(@"%ld tiles revealed", (long)self.totalNumberOfTilesRevealed);
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
                             stringWithFormat:@"%ld",
                                              (long)buttonWithCurrentIdentifier
                                                  .buttonStateModel
                                                  .numberOfNeighboringMines]
                forState:UIControlStateNormal];

            self.currentScoreValue +=
                self.levelNumberSelected *
                buttonWithCurrentIdentifier.buttonStateModel
                    .numberOfNeighboringMines;
        }
        self.currentScore.text =
            [NSString stringWithFormat:@"%ld", (long)self.currentScoreValue];
        //After each revelation check if user has won the game or not
        if([self didWinUserCurrentGameLiveCheck]) {
            [self verifyLossWinButtonPressed:nil];
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
    gameOverAlertView.tag = 13;
    [gameOverAlertView show];
}


- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 13) {
        
        if(self.gameState == OverAndWin || self.gameState == OverAndLoss) {
            [self showSaveScoreDialogueBox];
        }
        
        if (buttonIndex == 0) {
            [self resetGridWithNewTilesAndCompletionBlock:^{
                [self createNewGridWithParameters];
            }];
        }
    }
    else if(alertView.tag == 14){
        
        if(buttonIndex == 1) {
            NSString* inputUserName = [[alertView textFieldAtIndex:0] text];
            if(!inputUserName || inputUserName.length == 0) {
                inputUserName = @"User";
            }
            [ScoreSaver saveScoreInDatabaseWithUserName:inputUserName andScoreValue:self.currentScore.text andSelectedGameLevel:self.levelNumberSelected];
        }
    }
    else if (alertView.tag == 15) {
        if(buttonIndex == 1) {
            NSString* saveGameName = [[alertView textFieldAtIndex:0] text];
            
            //If it is a new game, save it with creation of new object
            if(self.gameStateNewLoaded == NewGame) {
                    [self saveCurrentGameInDataBaseWithName:saveGameName andToCreateNewObject:YES];
            }
            else{
                [UIAlertView bk_showAlertViewWithTitle:@"Save Game" message:@"Do you want to overwrite the existing game?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if(buttonIndex == 0){
                        [self saveCurrentGameInDataBaseWithName:saveGameName andToCreateNewObject:YES];
                    }
                    else {
                        [self saveCurrentGameInDataBaseWithName:saveGameName andToCreateNewObject:NO];
                    }
                }];
            }
            
            
        }
    }
}

-(void)saveCurrentGameInDataBaseWithName:(NSString*)gameName andToCreateNewObject:(BOOL)toCreateNewGame {
    
    RLMRealm* currentRealm = [RLMRealm defaultRealm];
    
    NSMutableArray* collectionOfAllButtons = [NSMutableArray new];
    [collectionOfAllButtons addObjectsFromArray:self.regularButtonsHolder];
    [collectionOfAllButtons addObjectsFromArray:self.minesButtonsHolder];
    
    NSData* gameDataToArchive = [NSKeyedArchiver archivedDataWithRootObject:collectionOfAllButtons];
    
    if(toCreateNewGame) {
        SaveGameModel* gameToStore = [SaveGameModel new];
        gameToStore.savedGameName = gameName;
        if(self.gameStateNewLoaded == NewGame) {
            gameToStore.identifier = self.currentGameIdentifier;
        }
        else {
            gameToStore.identifier = [JKRandomStringGenerator generateRandomStringWithLength:6];
        }
        
        gameToStore.timestampOfSave = [[NSDate date] timeIntervalSince1970];
        gameToStore.savedGameData = gameDataToArchive;
        gameToStore.levelNumber = self.levelNumberSelected;
        gameToStore.numberOfTilesInRow = self.gridSizeInputText.text;
        gameToStore.score = self.currentScoreValue;
        
        [currentRealm beginWriteTransaction];
        [currentRealm addObject:gameToStore];
        [currentRealm commitWriteTransaction];
        DLog(@"Created new game model");
    }
    else {
        RLMResults* savedGamesWithCurrentIdentifier = [SaveGameModel objectsWhere:[NSString stringWithFormat:@"identifier = '%@'",self.currentGameIdentifier]];
        if(([savedGamesWithCurrentIdentifier count] > 0) || !toCreateNewGame) {
            SaveGameModel* previouslyStoredModel = [savedGamesWithCurrentIdentifier firstObject];
            [currentRealm beginWriteTransaction];
            previouslyStoredModel.savedGameName = gameName;
            previouslyStoredModel.timestampOfSave = [[NSDate date] timeIntervalSince1970];
            previouslyStoredModel.savedGameData = gameDataToArchive;
            previouslyStoredModel.score = self.currentScoreValue;
            [currentRealm commitWriteTransaction];
            DLog(@"Updated game model");
    }
}
    
    [UIAlertView bk_showAlertViewWithTitle:@"Save Game" message:[NSString stringWithFormat:@"Game %@ Successfully stored in the database",gameName] cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
    [self.view endEditing:YES];
}


-(void)showSaveScoreDialogueBox {
    UIAlertView *saveGameScoreDialogue =
    [[UIAlertView alloc] initWithTitle:@"Minesweeper"
                               message:@"Please type name for this score"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"Ok", nil];
    saveGameScoreDialogue.tag = 14;
    saveGameScoreDialogue.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[saveGameScoreDialogue textFieldAtIndex:0] setText:@"User"];
    [saveGameScoreDialogue show];
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
        [self createNewGridWithParameters];
    }];
}

- (void)resetGridWithNewTilesAndCompletionBlock:
            (void (^)())resetTilesFinishedBlock {

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
        [self.audioOperationsManager playForegroundSoundFXnamed:@"revealed.wav" loop:NO];
        if (sender.tag == MINES_NOT_REVEALED_STATE) {
            sender.tag = MINES_REVEALED_STATE;
            [self.revealMenuButton setTitle:@"Hide" forState:UIControlStateNormal];
            for (
                 JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
                [individualTileWithMine addDecorationWithImage:[UIImage imageNamed:@"mine"] orColor:[UIColor greenColor]];
            }
        } else {
            sender.tag = MINES_NOT_REVEALED_STATE;
            [self.revealMenuButton setTitle:@"Reveal"
                               forState:UIControlStateNormal];
            for (
                 JKCustomButton *individualTileWithMine in self.minesButtonsHolder) {
                [individualTileWithMine addDecorationWithImage:nil orColor:[UIColor orangeColor]];
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
                    if(!self.animatedExplosionImage) {
                     self.animatedExplosionImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ANIMATED_IMAGE_URL]]];
                    }
                    
                    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
                    imageView.animatedImage = self.animatedExplosionImage;
                    imageView.frame = CGRectMake(0.0, 0.0,self.tileWidth, self.tileWidth);
                    [individualMinesButton addSubview:imageView];
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, GIF_IMAGE_ANIMATION_DURATION * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        imageView.image = [UIImage imageNamed:@"skull"];
                        [individualMinesButton setBackgroundColor:[UIColor redColor]];
                    });
                }
                completion:^(BOOL finished) {
                    individualMinesButton.buttonStateModel
                        .currentTileState = TileIsSelected;
                }];
        });
        time = dispatch_time(time, REGULAR_ANIMATION_DURATION * NSEC_PER_SEC);
    }
}

- (IBAction)levelNumberButtonPressed:(id)sender {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        //older than iOS 8 code here
        UIActionSheet *popup = [[UIActionSheet alloc]
                                initWithTitle:@"Select Target Level"
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
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    self.levelNumberSelected = levelNumber;
}

- (void)showiOS8ActionSheet {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Target Level"
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
                                        DLog(@"Cancel Button Pressed");
                                        
                                    }];
    
    [alertController addAction:easyLevel];
    [alertController addAction:mediumLevel];
    [alertController addAction:difficultLevel];
    [alertController addAction:expertLevel];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)changeGridBackgroundColorButtonPressed {
    self.currentViewForColorpicker = self.gridHolderView;
    [self setupColorPickerView];
}

- (IBAction)changeScrollViewBackgroundColorPressed:(id)sender {
    self.currentViewForColorpicker = self.superParentScrollView;
    [self setupColorPickerView];
}

-(void)setupColorPickerView {
    
    if(!self.colorPickerView) {
        self.colorPickerView = [[HRColorPickerView alloc] init];
        self.colorPickerView.colorInfoView.hidden = YES;
        self.colorPickerView.color = self.superParentScrollView.backgroundColor;
        [self.colorPickerView addTarget:self
                                 action:@selector(colorDidChanged:)
                       forControlEvents:UIControlEventValueChanged];
        self.colorPickerView.frame = CGRectMake(0, 0, 300, 300);
        self.colorPickerView.center = self.view.center;
        self.colorPickerView.alpha = 0.0;
        [self.view addSubview:self.colorPickerView];
        
        self.bottomViewForColorPicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.colorPickerView.frame.size.height, 54)];
        [self.bottomViewForColorPicker setBackgroundColor:[UIColor lightTextColor]];
        UIButton* hideColorPickerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 100, 44)];
        
        hideColorPickerButton.center = self.bottomViewForColorPicker.center;
        hideColorPickerButton.backgroundColor = [UIColor colorWithRed:200/255.0 green:210/255.0 blue:80/255.0 alpha:1.0];
        [hideColorPickerButton setTitle:@"Ok" forState:UIControlStateNormal];
        [hideColorPickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [hideColorPickerButton addTarget:self action:@selector(hideColorPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomViewForColorPicker addSubview:hideColorPickerButton];
        self.bottomViewForColorPicker.frame = CGRectMake(self.colorPickerView.frame.origin.x, self.colorPickerView.frame.size.height + self.colorPickerView.frame.origin.y, self.bottomViewForColorPicker.frame.size.width, self.bottomViewForColorPicker.frame.size.height);
        self.bottomViewForColorPicker.alpha = 0.0;
        [self.view addSubview:self.bottomViewForColorPicker];
    }
    self.bottomViewForColorPicker.alpha = 1.0;
    self.colorPickerView.alpha = 1.0;
}

-(IBAction)hideColorPickerView:(UIButton*)sender {
    self.colorPickerView.alpha = 0.0;
    self.bottomViewForColorPicker.alpha = 0.0;
}

- (void)colorDidChanged:(HRColorPickerView *)pickerView {
    [self.currentViewForColorpicker setBackgroundColor:pickerView.color];
}

- (IBAction)showPastScores:(UIButton *)sender {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    if(!self.pastScoresViewController) {
        self.pastScoresViewController = [[JKMinesweeperScoresViewController alloc] initWithNibName:@"JKMinesweeperScoresViewController" bundle:nil];
    }
    [self showInPopupWithView:self.pastScoresViewController.view];
}

- (IBAction)goToSettingsButtonPressed:(UIButton*)sender {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    if(!self.settingsViewController) {
        self.settingsViewController = [[JKMinesweeperSettingsViewController alloc] initWithNibName:@"JKMinesweeperSettingsViewController" bundle:nil];
    }
    [self showInPopupWithView:self.settingsViewController.view];
}


@end
