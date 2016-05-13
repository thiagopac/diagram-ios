/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class OptionsViewController;

@interface SelectColorSchemeController : UITableViewController {
   OptionsViewController *optionsViewController;
   NSArray *contents;
   NSInteger checkedRow;
}

- (id)initWithParentViewController:(OptionsViewController *) ovc;
- (void)deselect:(UITableView *)tableView;

@end

