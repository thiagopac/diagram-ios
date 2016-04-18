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

#import "Options.h"
#import "SimpleOptionTableController.h"


@implementation SimpleOptionTableController


- (id)initWithOption:(NSString *)anOptionName
parentViewController:(OptionsViewController *)ovc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      optionName = anOptionName;
      optionsViewController = ovc;
      [self setTitle: optionName];

      if ([optionName isEqualToString: @"Play style"]) {
         contents = @[@"Passive", @"Solid", @"Active", @"Aggressive", @"Suicidal"];
         slotName = @"playStyle";
      }
      else if ([optionName isEqualToString: @"Book variety"]) {
         contents = @[@"Low", @"Medium", @"High"];
         slotName = @"bookVariety";
      }
   }
   return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   return [contents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];

   UITableViewCell *cell =
      [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"cell"];
   }

   [[cell textLabel] setText:contents[row]];
   if ([[[cell textLabel] text] isEqualToString: [[Options sharedOptions]
                                                    valueForKey: slotName]]) {
      [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
      checkedRow = row;
   }

   return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:
   (NSIndexPath *)newIndexPath {
   NSInteger row = [newIndexPath row];

   [self performSelector: @selector(deselect:) withObject: tableView
              afterDelay: 0.1f];
   if (row != checkedRow) {
      [[Options sharedOptions]
         setValue: [[[tableView cellForRowAtIndexPath: newIndexPath] textLabel] text]
           forKey: slotName];
      [[tableView cellForRowAtIndexPath:
                     [NSIndexPath indexPathForRow: checkedRow
                                        inSection: 0]]
         setAccessoryType: UITableViewCellAccessoryNone];
      [[tableView cellForRowAtIndexPath: newIndexPath]
         setAccessoryType: UITableViewCellAccessoryCheckmark];
      checkedRow = row;
      [optionsViewController updateTableCells];
   }
   [[self navigationController] popViewControllerAnimated: YES];
}


- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}




@end
