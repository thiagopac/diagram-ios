/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class GameDetailsTableController;

@interface ResultTagViewController : UITableViewController {
   GameDetailsTableController *gameDetailsController;
   NSArray *contents;
   NSInteger checkedRow;
}

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc;
- (void)deselect:(UITableView *)tableView;


@end
