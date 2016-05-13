/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class SaveFileListController;

@interface TypeFileNameController : UITableViewController <UITextFieldDelegate> {
   SaveFileListController *saveFileListController;
   UITextField *textField;
}

- (id)initWithSaveFileListController:(SaveFileListController *)sflc;
- (void)doneButtonPressed:(id)sender;
- (void)deselect:(UITableView *)tableView;

@end
