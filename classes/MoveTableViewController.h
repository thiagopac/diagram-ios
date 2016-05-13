/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class BoardViewController;
@class Game;

@interface MoveTableViewController : UITableViewController {
   BoardViewController *boardViewController;
   Game *game;
   NSArray *moveList;
   int selectedRow;
}

- (id)initWithBoardViewController:(BoardViewController *)bvc game:(Game *)g;
- (void)donePressed;


@end
