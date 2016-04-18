/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
