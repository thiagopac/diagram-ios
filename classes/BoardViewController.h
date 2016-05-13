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
   UIView *contentView;
   UILabel *analysisView;
   UILabel *bookMovesView;
   BoardView *boardView;
   UILabel *whiteClockView, *blackClockView;
   UILabel *searchStatsView;
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

@property (nonatomic, readonly) UILabel *analysisView;
@property (nonatomic, readonly) UILabel *bookMovesView;
@property (nonatomic, readonly) BoardView *boardView;
@property (nonatomic, readonly) UILabel *whiteClockView;
@property (nonatomic, readonly) UILabel *blackClockView;
@property (nonatomic, readonly) MoveListView *moveListView;
@property (nonatomic, readonly) UILabel *searchStatsView;
@property (nonatomic, weak) GameController *gameController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

#pragma-mark CRIEI UMA VIEW PARA ADICIONAR OS BOTÕES DE NAVEGAÇÃO ENTRE AS JOGADAS
@property (nonatomic, strong) UIView *movesHistoryView;

- (void)toolbarButtonPressed:(id)sender;
- (void)showOptionsMenu;
- (void)optionsMenuDonePressed;
- (void)showLevelsMenu;
- (void)levelWasChanged;
- (void)gameModeWasChanged;
- (void)levelsMenuDonePressed;
- (void)scanNewPosition;
- (void)editPosition;
- (void)editPositionCancelPressed;
- (void)editPositionDonePressed:(NSString *)fen;
- (void)showSaveGameMenu;
- (void)saveMenuDonePressed;
- (void)saveMenuCancelPressed;
- (void)showLoadGameMenu;
- (void)moveListMenuDonePressed:(int)ply;
- (void)moveListMenuCancelPressed;
- (void)loadMenuCancelPressed;
- (void)loadMenuDonePressedWithGame:(NSString *)gameString;
- (void)showEmailGameMenu;
- (void)emailMenuDonePressed;
- (void)emailMenuCancelPressed;
- (void)stopActivityIndicator;
- (void)startActivityIndicator;
- (void)hideAnalysis;
- (void)hideBookMoves;
- (void)showBookMoves;
- (void)showMoveListMenu;

@end
