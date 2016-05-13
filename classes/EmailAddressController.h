/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class GameDetailsTableController;

@interface EmailAddressController : UITableViewController <UITextFieldDelegate> {
   GameDetailsTableController *gameDetailsController;
   UITextField *textField;
}

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc;
- (void)editingEnded:(NSNotification *)aNotification;
- (void)deselect:(UITableView *)tableView;

@end
