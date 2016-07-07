/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#import "BoardView.h"
#import "RootView.h"
#import "SGBaseMenu.h"

@class GameController;
@class MoveListView;

@interface BoardViewController : UIViewController <UIActionSheetDelegate> {
   RootView *rootView;
   UILabel *analysisView;
   UILabel *bookMovesView;
   BoardView *boardView;
   MoveListView *moveListView;
   GameController *__weak gameController;
   UINavigationController *navigationController;
   UIActionSheet *gameMenu, *newGameMenu, *moveMenu;
   UIBarButtonItem *gameButton, *optionsButton, *moveButton;
   UIPopoverController *optionsMenu, *saveMenu, *emailMenu, *levelsMenu, *loadMenu, *moveListMenu;
   UIPopoverController *popoverMenu;
   UIToolbar *toolbar;
   CGRect iPadBoardRectLandscape, iPadBoardRectPortrait,
      iPadWhiteClockRectPortrait, iPadWhiteClockRectLandscape,
      iPadBlackClockRectPortrait, iPadBlackClockRectLandscape,
      iPadMoveListRectPortrait, iPadMoveListRectLandscape,
      iPadAnalysisRectPortrait, iPadAnalysisRectLandscape,
      iPadSearchStatsRectPortrait, iPadSearchStatsRectLandscape,
      iPadBookRectLandscape, iPadBookRectPortrait;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, readonly) UILabel *analysisView;
@property (nonatomic, readonly) UILabel *bookMovesView;
@property (readonly, nonatomic) IBOutlet BoardView *boardView;
@property (nonatomic, readonly) MoveListView *moveListView;
@property (nonatomic, readonly) UILabel *searchStatsView;
@property (nonatomic, weak) GameController *gameController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

#pragma-mark CRIEI UMA VIEW PARA ADICIONAR OS BOTÕES DE NAVEGAÇÃO ENTRE AS JOGADAS
@property (strong, nonatomic) IBOutlet UIView *movesHistoryView;

- (void)loadMenuDonePressedWithGame:(NSString *)gameString;
- (void)toolbarButtonPressed:(id)sender;
- (void)levelWasChanged;
- (void)gameModeWasChanged;
- (void)scanNewPosition;
- (void)editPositionCancelPressed;
- (void)editPositionDonePressed:(NSString *)fen;
- (void)stopActivityIndicator;
- (void)startActivityIndicator;
- (void)hideLastMove;

@end
