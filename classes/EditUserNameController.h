/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class OptionsViewController;

@interface EditUserNameController : UITableViewController <UITextFieldDelegate> {
   OptionsViewController *parentViewController;
   UITextField *textField;
}

- (id)initWithParentViewController:(OptionsViewController *)ovc;
- (void)editingEnded:(NSNotification *)aNotification;
- (void)deselect:(UITableView *)tableView;

@end
