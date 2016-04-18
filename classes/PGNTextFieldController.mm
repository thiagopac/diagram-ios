/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski.

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

#import "Game.h"
#import "GameDetailsTableController.h"
#import "PGNTextFieldController.h"


@implementation PGNTextFieldController


- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc
                             pgnTag:(NSString *)tag {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      gameDetailsController = gdtc;
      pgnTag = tag;
      if ([pgnTag isEqualToString: @"whitePlayer"])
         [self setTitle: @"White"];
      else if ([pgnTag isEqualToString: @"blackPlayer"])
         [self setTitle: @"Black"];
      else if ([pgnTag isEqualToString: @"event"])
         [self setTitle: @"Event"];
      else if ([pgnTag isEqualToString: @"site"])
         [self setTitle: @"Site"];
      else if ([pgnTag isEqualToString: @"round"])
         [self setTitle: @"Round"];

      [[NSNotificationCenter defaultCenter]
         addObserver: self
            selector: @selector(editingEnded:)
                name: @"UITextFieldTextDidEndEditingNotification"
              object: nil];
      [self setPreferredContentSize: [gdtc preferredContentSize]];
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
   if (cell == nil)
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"cell" ];
    
   [[cell textLabel] setText: [self title]];
   textField = [[UITextField alloc]
                initWithFrame: CGRectMake(100, 2, 210,
                                          CGRectGetHeight([[cell contentView] frame]) - 2)];
   [textField setDelegate: self];
   [textField setBorderStyle: UITextBorderStyleNone];
   [textField setClearButtonMode: UITextFieldViewModeAlways];
   [textField setAutocorrectionType: UITextAutocorrectionTypeNo];
   [textField setFont: [UIFont systemFontOfSize: 14.0]];
   [textField becomeFirstResponder];
   NSString *s = [[gameDetailsController game] valueForKey: pgnTag];
   if ([s isEqualToString: @"?"])
      [textField setText: @""];
   else
      [textField setText: [[gameDetailsController game] valueForKey: pgnTag]];
   if ([pgnTag isEqualToString: @"whitePlayer"])
      [textField setPlaceholder: @"Enter white player's name"];
   else if ([pgnTag isEqualToString: @"blackPlayer"])
      [textField setPlaceholder: @"Enter black player's name"];
   else if ([pgnTag isEqualToString: @"event"])
      [textField setPlaceholder: @"Enter name of event"];
   else if ([pgnTag isEqualToString: @"site"])
      [textField setPlaceholder: @"Enter game site"];
   else if ([pgnTag isEqualToString: @"round"])
      [textField setPlaceholder: @"Enter tournament/match round"];
   
   [[cell contentView] addSubview: textField];

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
   NSString *value = [[textField text] isEqualToString: @""]? @"?" : [textField text];
   [[gameDetailsController game] setValue: value forKey: pgnTag];
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
