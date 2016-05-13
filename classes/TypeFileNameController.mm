/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import "SaveFileListController.h"
#import "TypeFileNameController.h"


@implementation TypeFileNameController

- (id)initWithSaveFileListController:(SaveFileListController *)sflc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      saveFileListController = sflc;
      UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                    initWithTitle: @"Done"
                                            style: UIBarButtonItemStylePlain
                                           target: self
                                           action: @selector(doneButtonPressed:)];
      [self setTitle: @"New file"];
      [[self navigationItem] setRightBarButtonItem: button];
      /*
       [self setPreferredContentSize: [sflc preferredContentSize]];
       */
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
   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"cell"];
      [[cell textLabel] setText: @"File name"];
      textField = [[UITextField alloc]
                   initWithFrame: CGRectMake(100, 2, 210,
                                             CGRectGetHeight([[cell contentView] frame]) - 2)];
      [textField setDelegate: self];
      [textField setBorderStyle: UITextBorderStyleNone];
      [textField setClearButtonMode: UITextFieldViewModeAlways];
      //[textField setAutocapitalizationType: UITextAutocapitalizationTypeNone];
      [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
      //[textField setText: [[Options sharedOptions] fullUserName]];
      [textField setFont: [UIFont systemFontOfSize: 14.0]];
      [textField setPlaceholder: @"Enter file name here"];
      [textField becomeFirstResponder];
      [[cell contentView] addSubview: textField];
   }
   return cell;
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)doneButtonPressed:(id)sender {
   [saveFileListController addFileName: [textField text]];
   [[self navigationController] popViewControllerAnimated: YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)tField {
   [saveFileListController addFileName: [textField text]];
   [[self navigationController] popViewControllerAnimated: YES];
   return NO;
}

- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}



@end
