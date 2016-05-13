/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class GameListController;
@class PGN;

@interface GamePreview : UITableViewController {
   PGN *pgnFile;
   GameListController *gameListController;
   int gameNumber;
   UIImage *backButtonImage, *forwardButtonImage;
   UIButton *backButton, *forwardButton;
   UIView *headerView;
   BOOL isReadonly;
}

- (id) initWithPGN:(PGN *)pgn gameNumber:(int)aNumber
gameListController:(GameListController *)glc
        isReadonly:(BOOL)readonly;
- (void)loadButtonPressed;

@end
