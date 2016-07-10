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
   BoardView *boardView;
   MoveListView *moveListView;
   GameController *__weak gameController;
   UINavigationController *navigationController;
    UIActionSheet *gameMenu;
   UIToolbar *toolbar;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (readonly, nonatomic) IBOutlet BoardView *boardView;
@property (nonatomic, readonly) MoveListView *moveListView;
@property (nonatomic, weak) GameController *gameController;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
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
