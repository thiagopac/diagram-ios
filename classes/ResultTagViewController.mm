/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "Game.h"
#import "GameDetailsTableController.h"
#import "ResultTagViewController.h"


@implementation ResultTagViewController

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      gameDetailsController = gdtc;
      contents = [NSArray arrayWithObjects:
                              @"1-0", @"0-1", @"1/2-1/2", @"*", nil];
      [self setPreferredContentSize: [gdtc preferredContentSize]];
      [self setTitle: @"Result"];
   }
   return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   return 4;
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
   [[cell textLabel] setText: [contents objectAtIndex: row]];
   if ([[[cell textLabel] text] isEqualToString: [[gameDetailsController game] result]]) {
      [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
      checkedRow = row;
   }
   else
      [cell setAccessoryType: UITableViewCellAccessoryNone];
   return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:
   (NSIndexPath *)newIndexPath {
   NSInteger row = [newIndexPath row];

   [self performSelector: @selector(deselect:) withObject: tableView
              afterDelay: 0.1f];
   if (row != checkedRow) {
      [[gameDetailsController game]
         setResult: [[[tableView cellForRowAtIndexPath: newIndexPath] textLabel] text]];
      [tableView reloadData];
      [gameDetailsController updateTableCells];
   }
   [[self navigationController] popViewControllerAnimated: YES];
}


- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}




@end

