/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class BoardViewController;

@interface LoadFileListController : UITableViewController {
   BoardViewController *__weak boardViewController;
   NSMutableArray *fileList;
   NSMutableArray *builtinFileList;
   BOOL firstAppearance;
}

@property (weak, nonatomic, readonly) BoardViewController *boardViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc;
- (void)updateTableCells;
- (void)deselect:(UITableView *)tableView;
- (void)removeItemWithFilename:(NSString *)filename;

@end
