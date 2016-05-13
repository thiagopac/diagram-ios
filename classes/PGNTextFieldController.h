/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class GameDetailsTableController;

@interface PGNTextFieldController : UITableViewController <UITextFieldDelegate> {
   GameDetailsTableController *gameDetailsController;
   NSString *pgnTag;
   UITextField *textField;
}

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc
                             pgnTag:(NSString *)tag;
- (void)editingEnded:(NSNotification *)aNotification;
- (void)deselect:(UITableView *)tableView;

@end
