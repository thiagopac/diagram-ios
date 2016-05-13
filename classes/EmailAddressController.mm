/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "EmailAddressController.h"
#import "GameDetailsTableController.h"
#import "Options.h"

@implementation EmailAddressController


- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      gameDetailsController = gdtc;
      [self setTitle: @"E-mail address"];
      [self setPreferredContentSize: [gdtc preferredContentSize]];
      [[NSNotificationCenter defaultCenter]
         addObserver: self
            selector: @selector(editingEnded:)
                name: @"UITextFieldTextDidEndEditingNotification"
              object: nil];
   }
   return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: @"email"];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"email"];
      [[cell textLabel] setText: @"E-mail"];
      textField = [[UITextField alloc]
                   initWithFrame: CGRectMake(100, 2, 210,
                                             CGRectGetHeight([[cell contentView] frame]) - 2)];
      [textField setDelegate: self];
      [textField setBorderStyle: UITextBorderStyleNone];
      [textField setText: [[Options sharedOptions] emailAddress]];
      [textField setClearButtonMode: UITextFieldViewModeAlways];
      [textField setAutocapitalizationType: UITextAutocapitalizationTypeNone];
      [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
      [textField setKeyboardType: UIKeyboardTypeEmailAddress];
      [textField setFont: [UIFont systemFontOfSize: 14.0]];
      [textField setPlaceholder: @"someone@example.com"];
      [textField becomeFirstResponder];
      [[cell contentView] addSubview: textField];
   }
   return cell;
}


- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}



- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)editingEnded:(NSNotification *)aNotification {
   [[Options sharedOptions] setEmailAddress: [textField text]];
   [gameDetailsController updateTableCells];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   [self editingEnded: nil];
   [[self navigationController] popViewControllerAnimated: YES];
   return NO;
}


- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver: self];
}


@end
