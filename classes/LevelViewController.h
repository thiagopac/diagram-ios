/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class BoardViewController;

@interface LevelViewController : UITableViewController {
   BoardViewController *boardViewController;
}

- (id)initWithBoardViewController:(BoardViewController *)bvc;
- (void)deselect:(UITableView *)tableView;

@end
