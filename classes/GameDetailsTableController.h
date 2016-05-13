/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class BoardViewController;
@class Game;

@interface GameDetailsTableController : UITableViewController {
   BoardViewController *boardViewController;
   Game *__weak game;
   BOOL email;
}

@property (weak, nonatomic, readonly) Game *game;

- (id)initWithBoardViewController:(BoardViewController *)bvc
                             game:(Game *)aGame
                            email:(BOOL)mail;
- (void)deselect:(UITableView *)tableView;
- (void)updateTableCells;
- (void)emailMenuDonePressed;
- (void)saveMenuDonePressed;

@end
