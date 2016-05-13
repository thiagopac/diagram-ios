/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#import "OptionsViewController.h"

@interface SimpleOptionTableController : UITableViewController {
   NSString *optionName;
   NSArray *contents;
   NSString *slotName;
   NSInteger checkedRow;
   OptionsViewController *optionsViewController;
}

- (id)initWithOption:(NSString *)anOptionName
parentViewController:(OptionsViewController *)ovc;
- (void)deselect:(UITableView *)tableView;

@end
