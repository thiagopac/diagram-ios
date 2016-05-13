/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "EditUserNameController.h"
#import "Options.h"
#import "OptionsViewController.h"


@implementation EditUserNameController

- (id)initWithParentViewController:(OptionsViewController *)ovc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      parentViewController = ovc;
      [self setTitle: @"Your name"];

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
   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: @"username"];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"username"];
      [[cell textLabel] setText: @"Name"];
      textField = [[UITextField alloc]
                   initWithFrame: CGRectMake(100, 2, /*210,*/
                         cell.contentView.frame.size.width - 110,
                         cell.contentView.frame.size.height - 2)];
      [textField setDelegate: self];
      [textField setBorderStyle: UITextBorderStyleNone];
      [textField setClearButtonMode: UITextFieldViewModeAlways];
      //[textField setAutocapitalizationType: UITextAutocapitalizationTypeNone];
      [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
      [textField setText: [[Options sharedOptions] fullUserName]];
      [textField setFont: [UIFont systemFontOfSize: 14.0]];
      [textField setPlaceholder: @"Enter your name here"];
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
   [[Options sharedOptions] setFullUserName: [textField text]];
   [parentViewController updateTableCells];
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
