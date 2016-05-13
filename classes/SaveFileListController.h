/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class GameDetailsTableController;

@interface SaveFileListController : UITableViewController {
   GameDetailsTableController *gameDetailsController;
   NSMutableArray *fileList;
   NSInteger checkedRow, checkedSection;
}

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc;
- (void)deselect:(UITableView *)tableView;
- (void)newFile:(id)sender;
- (void)addFileName:(NSString *)aNewFileName;

@end
