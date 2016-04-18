/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski.

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <UIKit/UIKit.h>

#import "BoardView.h"
#import "RootView.h"

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
   UIActivityIndicatorView *activityIndicator;
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
- (void)hideAnalysis;
- (void)hideBookMoves;
- (void)showBookMoves;
- (void)showMoveListMenu;

@end
