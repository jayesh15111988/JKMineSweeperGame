//
//  JKMinesweeperHomeViewController.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

#import <FLAnimatedImage.h>
#import <Realm.h>
#import <UIAlertView+BlocksKit.h>
#import <ReactiveCocoa.h>
#import <RLMResults.h>
#import <NSArray+BlocksKit.h>
#import <KLCPopup.h>
#import "SaveGameModel.h"
#import <JKAutolayoutReadyScrollView/ScrollViewAutolayoutCreator.h>
#import "JKAudioOperations.h"
#import "JKRandomStringGenerator.h"
#import "JKNeighbouringTilesProvider.h"
#import "JKMineSweeperConstants.h"
#import "JKCustomButton.h"
#import "UIButton+Utility.h"
#import "JKButtonStateModel.h"
#import "JKMinesweeperSavedGamesViewController.h"
#import "ScoreSaver.h"
#import "JKMinesweeperScoresViewController.h"
#import "RandomNumberGenerator.h"
#import "JKMinesweeperSettingsViewController.h"
#import "JKTimerProviderUtility.h"
#import "ColorPickerProvider.h"

#import "JKMinesweeperHomeViewController.h"

typedef void (^resetTilesFinishedBlock)();

@interface JKMinesweeperHomeViewController ()

@property(weak, nonatomic) IBOutlet UITextField *gridSizeInputText;
@property(strong, nonatomic) UIView *gridHolderView;
@property(strong, nonatomic) NSMutableDictionary *minesLocationHolder;
@property(assign, nonatomic) NSInteger totalNumberOfMinesOnGrid;
@property (weak, nonatomic) IBOutlet UIView *topHeaderOptionsView;
@property (strong, nonatomic) ScrollViewAutolayoutCreator* scrollViewAutoLayout;
@property (strong, nonatomic) UIView *gridHolderSuperView;

@property (strong, nonatomic) NSTimer* createNewGridAnimationTimer;
@property (assign, nonatomic) NSInteger newMinesCurrentObjectIndex;
@property (strong, nonatomic) NSTimer* destroyCurrentGridAnimationTimer;
@property (strong, nonatomic) NSTimer* blastMinesAnimationTimer;
@property (assign, nonatomic) NSInteger totalNumberMinesToExplode;

@property (strong, nonatomic) UIView* currentViewForColorpicker;
@property (strong, nonatomic) NSString* currentGameIdentifier;
@property (strong, nonatomic) FLAnimatedImage *animatedExplosionImage;
@property (weak, nonatomic) IBOutlet UIButton *changeScrollViewBackgroundColorButton;
@property (weak, nonatomic) IBOutlet UIImageView *gameProgressIndicatorImage;

@property (strong, nonatomic) UIView* colorPickerHolderView;
@property (assign, nonatomic) CurrentGameState gameState;
@property (assign, nonatomic) SoundCategory soundCategory;
@property (assign, nonatomic) GameState gameStateNewLoaded;
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
    self.levelNumberSelected = 1;
    self.audioOperationsManager = [[JKAudioOperations alloc] init];
    self.gridHolderView = [[UIView alloc] init];
    self.gridHolderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.minesLocationHolder = [NSMutableDictionary new];
    self.minesButtonsHolder = [NSMutableArray new];
    self.regularButtonsHolder = [NSMutableArray new];
    self.numberOfSurroundingMinesHolder = [NSMutableDictionary new];
    self.newMinesCurrentObjectIndex = 0;
    self.totalNumberMinesToExplode = 0;
    [self setupRACSignalsAndNotifications];
    [self playGameStartSound];
    [self createNewGridWithParameters];
}

- (void)makeTileVisibleForCurrentIndex:(NSTimer*)timer {
    if (self.newMinesCurrentObjectIndex < self.maximumTileSequence) {
        JKCustomButton* currentViewToMakeVisible = self.gridHolderView.subviews[self.newMinesCurrentObjectIndex];
        currentViewToMakeVisible.alpha = 1.0;
        self.newMinesCurrentObjectIndex++;
    } else {
        DLog(@"Timer stopped");
        // Reset all parameters after animation is fully complete.
        self.newMinesCurrentObjectIndex = 0;
        [self.createNewGridAnimationTimer invalidate];
        self.createNewGridAnimationTimer = nil;
        self.gameState = NotStarted;
        DLog(@"Gridholder subviews count %ld", (long)self.gridHolderView.subviews.count);
    }
}

- (void)destroyCurrentGrid:(NSTimer*)timer {
    if (self.newMinesCurrentObjectIndex < self.maximumTileSequence) {
        JKCustomButton* currentViewToMakeVisible = [self.gridHolderView.subviews lastObject];
        [currentViewToMakeVisible removeFromSuperview];
        self.newMinesCurrentObjectIndex++;
    } else {
        self.newMinesCurrentObjectIndex = 0;
        [self.destroyCurrentGridAnimationTimer invalidate];
        self.gameState = NotStarted;
        self.destroyCurrentGridAnimationTimer = nil;
        [self createNewGridWithParameters];
    }
}

- (void)blastMineswithanimation:(NSTimer*)timer {
    if (self.totalNumberMinesToExplode < self.minesButtonsHolder.count) {
        JKCustomButton* currentMine = self.minesButtonsHolder[self.totalNumberMinesToExplode];
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        imageView.animatedImage = self.animatedExplosionImage;
        imageView.frame = CGRectMake(0.0, 0.0,self.tileWidth, self.tileWidth);
        [currentMine addSubview:imageView];
        [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            imageView.image = [UIImage imageNamed:@"skull"];
            [currentMine setBackgroundColor:[UIColor redColor]];
        } completion:^(BOOL finished) {
            currentMine.buttonStateModel
            .currentTileState = TileSelected;
        }];
        self.totalNumberMinesToExplode++;
    } else {
        [self.blastMinesAnimationTimer invalidate];
        self.blastMinesAnimationTimer = nil;
    }
}

- (void)showAllMines {
    
    if (!self.animatedExplosionImage) {
        self.animatedExplosionImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ANIMATED_IMAGE_URL]]];
    }
    self.totalNumberMinesToExplode = 0;
    self.destroyCurrentGridAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:(DEFAULT_TOTAL_ANIMATION_DURATION/self.maximumTileSequence) target:self selector:@selector(blastMineswithanimation:) userInfo:nil repeats:YES];
    [self.destroyCurrentGridAnimationTimer fire];
}

- (void)resetGridWithNewTiles {
    self.resetButton.enabled = NO;
    self.revealMenuButton.enabled = NO;
    [self.minesLocationHolder removeAllObjects];
    [self.regularButtonsHolder removeAllObjects];
    [self.minesButtonsHolder removeAllObjects];
    [self.numberOfSurroundingMinesHolder removeAllObjects];
    self.totalNumberOfTilesRevealed = 0;
    self.currentScoreValue = 0;
    self.currentScore.text = @"0";
    self.destroyCurrentGridAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:(DEFAULT_TOTAL_ANIMATION_DURATION/self.maximumTileSequence) target:self selector:@selector(destroyCurrentGrid:) userInfo:nil repeats:YES];
    [self.destroyCurrentGridAnimationTimer fire];
    self.gameState = Busy;
}

-(void)setupRACSignalsAndNotifications {
    
     [[[NSNotificationCenter defaultCenter] rac_addObserverForName:HIDE_POPOVER_VIEW_NOTIFICATION object:nil] subscribeNext:^(id x) {
         [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
         [self.popupView dismiss:YES];
     }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:TIMER_VALUE_CHANGED object:nil] subscribeNext:^(id x) {
        [self updateUIWithNewTimeValue];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOUND_SETTINGS_CHANGED object:nil] subscribeNext:^(id x) {
            [self updateSounds];
    }];
    
    [RACObserve(self, levelNumberSelected) subscribeNext:^(NSNumber* levelNumber) {
        [[NSUserDefaults standardUserDefaults] setObject:levelNumber forKey:@"currentLevel"];
        [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
        [self.levelNumberButton setTitle:[NSString stringWithFormat:@"Level %ld",(long)([levelNumber integerValue])] forState:UIControlStateNormal];
    }];
    
    [RACObserve(self, currentViewForColorpicker) subscribeNext:^(id x) {
        if (x) {
            [self setupColorPickerView];
        }
    }];
    
    [[self.changeScrollViewBackgroundColorButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       self.colorPickerHolderView.hidden = NO;
       self.currentViewForColorpicker = self.scrollViewAutoLayout.contentView;
    }];
    
    self.verifyLossWinButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self verifyLossWinButtonPressedWithUserWonCurrentGame:NO];
        return [RACSignal empty];
    }];
    
    self.levelNumberButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self levelNumberButtonPressed];
        return [RACSignal empty];
    }];
    
    [RACObserve(self, totalNumberOfTilesRevealed) subscribeNext:^(NSNumber *numberOfTilesUnleashed) {
        if ([numberOfTilesUnleashed integerValue] > 0) {
            self.gameState = InProgress;
        }
    }];
    
    [RACObserve(self, gameState) subscribeNext:^(NSNumber *currentGameState) {
        GameState updatedGameState = [currentGameState integerValue];
        BOOL gameInProgress = (updatedGameState == InProgress);
        self.saveButton.hidden = !gameInProgress;
        
        NSString* gameProgressIndicatorImageName = @"bullet_grey";
        switch (updatedGameState) {
            case InProgress:
                gameProgressIndicatorImageName = @"bullet_green";
                break;
            case Busy:
                gameProgressIndicatorImageName = @"bullet_red";
                break;
            default:
                break;
        }
        self.gameProgressIndicatorImage.image = [UIImage imageNamed:gameProgressIndicatorImageName];
        [self updateUIWithNewTimeValue];
    }];
    
    self.saveButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(UIButton* _) {
        
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        
        
        UIAlertView *saveGameScoreDialogue = [UIAlertView bk_alertViewWithTitle:@"Save Game" message:@"Please type your name for this game"];
        saveGameScoreDialogue.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[saveGameScoreDialogue textFieldAtIndex:0] setText:[formatter stringFromDate:[NSDate date]]];
        [saveGameScoreDialogue bk_setCancelButtonWithTitle:@"Cancel" handler:NULL];
        [saveGameScoreDialogue bk_addButtonWithTitle:@"OK" handler:^{
            NSString* saveGameName = [[saveGameScoreDialogue textFieldAtIndex:0] text];
            //If it is a new game, save it with creation of new object
            if (self.gameStateNewLoaded == NewGame) {
                [self saveCurrentGameInDataBaseWithName:saveGameName andToCreateNewObject:YES];
            } else{
                [UIAlertView bk_showAlertViewWithTitle:@"Save Game" message:@"Do you want to overwrite the existing game?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0){
                        [self saveCurrentGameInDataBaseWithName:saveGameName andToCreateNewObject:YES];
                    } else {
                        [self saveCurrentGameInDataBaseWithName:saveGameName andToCreateNewObject:NO];
                    }
                }];
            }
        }];
        [saveGameScoreDialogue show];
        return [RACSignal empty];
    }];

    @weakify(self)
    self.loadButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(UIButton* _) {
        @strongify(self)
        if (!self.savedGamesViewController) {
            self.savedGamesViewController = [[JKMinesweeperSavedGamesViewController alloc] initWithNibName:@"JKMinesweeperSavedGamesViewController" bundle:nil];
            @weakify(self)
            self.savedGamesViewController.openSelectedGameModel = ^(SaveGameModel* selectedGameModel) {
                @strongify(self)
                [self resetGameBeforeLoadingPreviousGame:selectedGameModel];
                //Now load all tiles on the front page
                NSArray *allCustomButtonCollection=[NSKeyedUnarchiver unarchiveObjectWithData:selectedGameModel.savedGameData];
                
                NSArray* collectionWithSelectedTiles = [allCustomButtonCollection bk_select:^BOOL(JKCustomButton* currentButtonObject) {
                    TileStateRepresentationValue currentButtonState = currentButtonObject.buttonStateModel.currentTileState;
                    return (currentButtonState == TileSelected || currentButtonState == TileQuestionMarked);
                }];
                
                DLog(@"%ld and %ld", (long)self.regularButtonsHolder.count, (long)self.minesButtonsHolder.count);
                
                self.totalNumberOfTilesRevealed = [collectionWithSelectedTiles count];
                
                for (JKCustomButton* individualButton in allCustomButtonCollection) {
                    DLog(@"In button mine %ld Sequence number %ld current tile state %ld ", (long)individualButton.buttonStateModel.isThisButtonMine, (long)individualButton.buttonSequenceNumber, (long)individualButton.buttonStateModel.currentTileState);
                    individualButton.frame = CGRectMake(individualButton.positionOnScreen.x, individualButton.positionOnScreen.y, self.tileWidth, self.tileWidth);
                    
                    [individualButton configurePreviousButton:individualButton.positionOnScreen andWidth:self.tileWidth andButtonState:individualButton.buttonStateModel];
                    

                    if (individualButton.buttonStateModel.isThisButtonMine) {
                        [self.minesButtonsHolder addObject:individualButton];
                    } else {
                        [self.regularButtonsHolder addObject:individualButton];
                    }
                    
                    //For each button retrieved from database, we will add long press gesture to it
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                    [individualButton addGestureRecognizer:longPress];
                    
                    individualButton.gameOverInstant = ^() {
                        [self showAllMines];
                        self.gameState = OverAndLoss;
                        [self showAlertViewWithMessage:@"You clicked on mine and now game is over"];
                        [self playGameOverSound];
                    };
                    
                    individualButton.randomTileSelectedInstant = ^(NSInteger buttonSequenceNumber) {
                        if (![self isGameOver]) {
                            [self highlightNeighbouringButtonsForButtonSequence: buttonSequenceNumber];
                        }
                    };
                    [self.gridHolderView addSubview:individualButton];
                }
            };
        }
        [self showInPopupWithView:self.savedGamesViewController.view];
        return [RACSignal empty];
    }];
    
    self.timerIndicatorButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(UIButton* _) {
        if (self.timerProviderUtility.currentTimerState == TimerIsPlaying) {
            [self.audioOperationsManager stopBackgroundMusic];
            [self.timerProviderUtility pauseTimer];
        } else {
            [self.timerProviderUtility startTimer];
        }
        return [RACSignal empty];
    }];
}

- (void)showInPopupWithView:(UIView*)inputPopupView {
    self.popupView = [KLCPopup popupWithContentView:inputPopupView showType:KLCPopupShowTypeSlideInFromBottom dismissType:KLCPopupDismissTypeSlideOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    if (IS_OS_8_OR_LATER) {
        inputPopupView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    [self.popupView show];
}

-(void)resetGameBeforeLoadingPreviousGame:(SaveGameModel*)selectedGameModel {
    
    // Unreveal all tiles if they are revealed in the previous game.
    if (self.revealMenuButton.tag == MINES_REVEALED_STATE) {
        [self resetRevealMenuButton];
    }
    
    self.gameStateNewLoaded = SavedGame;
    self.currentScoreValue = selectedGameModel.score;
    self.currentScore.text = [NSString stringWithFormat:@"%ld",(long)self.currentScoreValue];
    self.levelNumberSelected = selectedGameModel.levelNumber;
    self.gridSizeInputText.text = selectedGameModel.numberOfTilesInRow;
    self.totalNumberOfRequiredTiles = [self.gridSizeInputText.text integerValue];

    // Setup Grid size to match the one number of tiles here.
    [self setupGridHolderView];
    if (self.totalNumberOfRequiredTiles < 3) {
        self.totalNumberOfRequiredTiles = 3;
    }
    //We will use previous identifier and will use to overwrite existing game
    self.currentGameIdentifier = selectedGameModel.identifier;
    NSArray *allButtonsInGridView = [self.gridHolderView subviews];
    for (UIView *individualButtonOnGrid in allButtonsInGridView) {
        [individualButtonOnGrid removeFromSuperview];
    }
    [self.regularButtonsHolder removeAllObjects];
    [self.minesButtonsHolder removeAllObjects];
}

-(void)updateSounds {
    BOOL isSoundEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
    
    if (isSoundEnabled) {
        [self playBackgroundSound];
    }
    else {
        [self.audioOperationsManager stopBackgroundMusic];
    }
}

-(void)updateUIWithNewTimeValue {
    self.timerIndicatorButton.hidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"timer"] boolValue];
    if (!self.timerIndicatorButton.hidden) {
        if (self.gameState == InProgress) {
            if (self.timerProviderUtility.currentTimerState != TimerIsPaused) {
                if (!self.timerProviderUtility) {
                    self.timerProviderUtility = [[JKTimerProviderUtility alloc] init];
                    @weakify(self)
                    self.timerProviderUtility.UpdateTimerLabelBlock = ^(NSString* updatedTimerLabelValue) {
                    @strongify(self)
                    [self.timerIndicatorButton setTitle:updatedTimerLabelValue forState:UIControlStateNormal];
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
    self.currentScoreValue = 0;
    self.totalNumberOfTilesRevealed = 0;
    [self updateUIWithNewTimeValue];
}

- (void)createNewGridWithParameters {

    self.gameState = NotStarted;
    self.gameStateNewLoaded = NewGame;
    
    [self setupUIFromUserDefaultParameters];
    [self resetRevealMenuButton];
    self.totalNumberOfRequiredTiles = [self.gridSizeInputText.text integerValue];

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

- (void)verifyLossWinButtonPressedWithUserWonCurrentGame:(BOOL)userWonCurrentGame {

    //We are prechecking if user has won this game after checking status for each tile revealed. Sender is nil if user has already won this game. If button has manual entry, then user is probably still in the game
    
    BOOL didUserWinCurrentGame = userWonCurrentGame;
    
    NSString *currentGameStatusMessage = @"N/A";
    
    if (self.gameState != NotStarted) {
        if (didUserWinCurrentGame) {
            [self.audioOperationsManager playForegroundSoundFXnamed:@"gamewin.wav" loop:NO];
            [self.audioOperationsManager stopBackgroundMusic];
            self.gameState = OverAndWin;
            currentGameStatusMessage = @"You won this game. Click the button "
            @"below to start a new game";
        } else {
            if (self.gameState != OverAndLoss) {
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
    [self setPositionOfChangeBackgroundColorButton];
    return gridHeightAndWidth;
}

- (void)createNewGridOnScreen {

    //[self resetGridWithNewTiles];
    self.resetButton.enabled = YES;
    self.revealMenuButton.enabled = YES;

    [self populateMinesHolderWithMinesLocationsWithMaximumGridWidth:self.totalNumberOfRequiredTiles];
    
    NSInteger gridHeightAndWidth = [self setupGridHolderView];
    
    [self.gridHolderView setBackgroundColor:[UIColor lightGrayColor]];
    
    
    //if (self.gridHolderView.subviews.count) {
    //    [self.gridHolderView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    //}
    
    NSInteger buttonSequenceNumber = 0;
    BOOL doesMineExistForTile = NO;
    NSInteger totalNumberOfMinesSurroundingGivenTile = 0;

    //dispatch_time_t time = DISPATCH_TIME_NOW;
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

            @weakify(self)

            newRevealMineButton.gameOverInstant = ^() {
                @strongify(self)
                [self showAllMines];
                self.gameState = OverAndLoss;
                [self showAlertViewWithMessage:@"You clicked on mine and "
                            @"game is now over"];
                [self playGameOverSound];
                
            };

            newRevealMineButton.randomTileSelectedInstant =
                ^(NSInteger buttonSequenceNumber) {
                    @strongify(self)
                    if (![self isGameOver]) {
                        [self highlightNeighbouringButtonsForButtonSequence: buttonSequenceNumber];
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
        }
    }
    
    if (self.gridHolderSuperView) {
        [self.gridHolderSuperView removeFromSuperview];
    }
    self.gridHolderSuperView = [UIView new];
    self.gridHolderSuperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.gridHolderSuperView];
    self.gridHolderView.backgroundColor = [UIColor redColor];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_gridHolderSuperView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_gridHolderSuperView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_topHeaderOptionsView][_gridHolderSuperView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_topHeaderOptionsView, _gridHolderSuperView)]];
    
    self.scrollViewAutoLayout = [[ScrollViewAutolayoutCreator alloc] initWithSuperView:self.gridHolderSuperView];
    [self.scrollViewAutoLayout.contentView addSubview:self.gridHolderView];
    [self.scrollViewAutoLayout.contentView addSubview:self.changeGridBakcgroundColorButton];
    [self.scrollViewAutoLayout.contentView setBackgroundColor:[UIColor colorWithRed:0.94 green:0.67 blue:0.3 alpha:1.0]];
    
    self.createNewGridAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:(DEFAULT_TOTAL_ANIMATION_DURATION/self.maximumTileSequence) target:self selector:@selector(makeTileVisibleForCurrentIndex:) userInfo:nil repeats:YES];
    [self.createNewGridAnimationTimer fire];
    self.gameState = Busy;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridHolderView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.gridHolderSuperView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridHolderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:gridHeightAndWidth]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_gridHolderView(totalGridViewHeight)]-20-|" options:kNilOptions metrics:@{@"totalGridViewHeight": @(gridHeightAndWidth)} views:NSDictionaryOfVariableBindings(_gridHolderView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_gridHolderView]-10-[_changeGridBakcgroundColorButton(30)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_gridHolderView, _changeGridBakcgroundColorButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_changeGridBakcgroundColorButton(30)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings( _changeGridBakcgroundColorButton)]];
    
}

-(void)playGameOverSound {
    [self.audioOperationsManager stopBackgroundMusic];
    [self.audioOperationsManager playForegroundSoundFXnamed:@"explosion.wav"  loop:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, DEFAULT_TOTAL_ANIMATION_DURATION * NSEC_PER_SEC);
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
        if (longPressedButton.buttonStateModel.currentTileState == TileSelected) {
            return;
        }
        
        if (longPressedButton.buttonStateModel.currentTileState == TileQuestionMarked) {
            longPressedButton.buttonStateModel.currentTileState = TileNotSelected;
        }
        else {
            longPressedButton.buttonStateModel.currentTileState = TileQuestionMarked;
        }
        
        if (longPressedButton.buttonStateModel.currentTileState == TileQuestionMarked) {
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
   
    if (!self.changeGridBakcgroundColorButton) {
        self.changeGridBakcgroundColorButton = [[UIButton alloc] init];
        self.changeGridBakcgroundColorButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.changeGridBakcgroundColorButton setBackgroundImage:[UIImage imageNamed:@"changeColor"] forState:UIControlStateNormal];
        [[self.changeGridBakcgroundColorButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            self.colorPickerHolderView.hidden = NO;
            self.currentViewForColorpicker = self.gridHolderView;
        }];
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
            TileSelected;
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
        if ([self didWinUserCurrentGameLiveCheck]) {
            [self verifyLossWinButtonPressedWithUserWonCurrentGame:YES];
        }
    }
}

- (void)showAlertViewWithMessage:(NSString *)message {
    [UIAlertView bk_showAlertViewWithTitle:@"Minesweeper" message:message cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Continue"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (self.gameState == OverAndWin || self.gameState == OverAndLoss) {
            [self showSaveScoreDialogueBox];
        }
    }];
}

-(void)saveCurrentGameInDataBaseWithName:(NSString*)gameName andToCreateNewObject:(BOOL)toCreateNewGame {
    
    RLMRealm* currentRealm = [RLMRealm defaultRealm];
    
    NSMutableArray* collectionOfAllButtons = [NSMutableArray new];
    [collectionOfAllButtons addObjectsFromArray:self.regularButtonsHolder];
    [collectionOfAllButtons addObjectsFromArray:self.minesButtonsHolder];
    
    NSData* gameDataToArchive = [NSKeyedArchiver archivedDataWithRootObject:collectionOfAllButtons];
    
    if (toCreateNewGame) {
        SaveGameModel* gameToStore = [SaveGameModel new];
        gameToStore.savedGameName = gameName;
        if (self.gameStateNewLoaded == NewGame) {
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
    } else {
        RLMResults* savedGamesWithCurrentIdentifier = [SaveGameModel objectsWhere:[NSString stringWithFormat:@"identifier = '%@'",self.currentGameIdentifier]];
        if (([savedGamesWithCurrentIdentifier count] > 0) || !toCreateNewGame) {
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
    
    [UIAlertView bk_showAlertViewWithTitle:@"Save Game" message:[NSString stringWithFormat:@"Game %@ Successfully stored in the database",gameName] cancelButtonTitle:@"OK" otherButtonTitles:nil handler:NULL];
    [self.view endEditing:YES];
}


-(void)showSaveScoreDialogueBox {
    UIAlertView *saveGameScoreDialogue = [UIAlertView bk_alertViewWithTitle:@"Minesweeper" message:@"Please type name for this score"];
    saveGameScoreDialogue.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[saveGameScoreDialogue textFieldAtIndex:0] setText:@"User"];
    [saveGameScoreDialogue bk_setCancelButtonWithTitle:@"Cancel" handler:NULL];
    [saveGameScoreDialogue bk_addButtonWithTitle:@"OK" handler:^{
        NSString* inputUserName = [[saveGameScoreDialogue textFieldAtIndex:0] text];
        if (!inputUserName || inputUserName.length == 0) {
            inputUserName = @"User";
        }
        [ScoreSaver saveScoreInDatabaseWithUserName:inputUserName andScoreValue:self.currentScore.text andSelectedGameLevel:self.levelNumberSelected];
        [self resetGridWithNewTiles];
    }];
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

        generateRandomMinesSequence = [RandomNumberGenerator randomNumberBetweenMin:0 andMax:self.maximumTileSequence];
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

- (IBAction)resetButtonPressed:(UIButton *)sender {
    [self resetGridWithNewTiles];
}

- (IBAction)revealMinesButtonPressed:(UIButton *)sender {
    
    if (self.minesButtonsHolder.count > 0) {
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

- (void)levelNumberButtonPressed {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    UIAlertView* alertView = [[UIAlertView alloc] init];
    [alertView bk_addButtonWithTitle:@"Easy" handler:NULL];
    [alertView bk_addButtonWithTitle:@"Medium" handler:NULL];
    [alertView bk_addButtonWithTitle:@"Difficult" handler:NULL];
    [alertView bk_addButtonWithTitle:@"Expert" handler:NULL];
    [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:NULL];
    [alertView show];
    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber* buttonClickedIndex) {
        if ([buttonClickedIndex integerValue] <= 3) {
            self.levelNumberSelected = [buttonClickedIndex integerValue] + 1;
        }
    }];
}

-(void)setupColorPickerView {
    if (!self.colorPickerHolderView) {
        @weakify(self)
       self.colorPickerHolderView = [ColorPickerProvider colorPickerForCurrentViewForParentView:self.gridHolderSuperView andColorChangedBlock:^(UIColor *selectedColor) {
           @strongify(self)
           [self.currentViewForColorpicker setBackgroundColor:selectedColor];
       }];
    }
    [ColorPickerProvider changeColorPickerColorWithNewColor:self.currentViewForColorpicker.backgroundColor];
}

- (IBAction)showPastScores:(UIButton *)sender {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    if (!self.pastScoresViewController) {
        self.pastScoresViewController = [[JKMinesweeperScoresViewController alloc] initWithNibName:@"JKMinesweeperScoresViewController" bundle:nil];
    }
    [self showInPopupWithView:self.pastScoresViewController.view];
}

- (IBAction)goToSettingsButtonPressed:(UIButton*)sender {
    [self.audioOperationsManager playForegroundSoundFXnamed:@"openmenu.wav" loop:NO];
    if (!self.settingsViewController) {
        self.settingsViewController = [[JKMinesweeperSettingsViewController alloc] initWithNibName:@"JKMinesweeperSettingsViewController" bundle:nil];
    }
    [self showInPopupWithView:self.settingsViewController.view];
}

@end
