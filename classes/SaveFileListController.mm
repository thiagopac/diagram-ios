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

#import "GameDetailsTableController.h"
#import "Options.h"
#import "PGN.h"
#import "SaveFileListController.h"
#import "TypeFileNameController.h"


@implementation SaveFileListController

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      gameDetailsController = gdtc;
      [self setTitle: @"Game files"];

      UIBarButtonItem *button =
         [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                 target: self
                                 action: @selector(newFile:)];
      [self setPreferredContentSize: [gdtc preferredContentSize]];
      [[self navigationItem] setRightBarButtonItem: button];

      fileList =
         (NSMutableArray *)
         [[[NSFileManager defaultManager]
              contentsOfDirectoryAtPath: PGN_DIRECTORY error: NULL]
             pathsMatchingExtensions: [NSArray arrayWithObjects: @"pgn", nil]];
   }
   return self;
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   return section == 0? 1 : [fileList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger section = [indexPath section];
   NSInteger row = [indexPath row];
   NSString *oldSaveGameFile = [[Options sharedOptions] saveGameFile];

   UITableViewCell *cell =
      [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil) {
       cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: @"cell"];
   }
   
   [[cell textLabel] setText: ((section == 0)? @"Clipboard" : [fileList objectAtIndex: row])];
   if ([[[cell textLabel] text] isEqualToString: oldSaveGameFile]
       || ([fileList count] == 1 && section == 1 && ![oldSaveGameFile isEqualToString: @"Clipboard"])) {
      [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
      checkedRow = row;
      checkedSection = section;
   } else [cell setAccessoryType: UITableViewCellAccessoryNone];

   return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:
   (NSIndexPath *)newIndexPath {
   NSInteger row = [newIndexPath row];
   NSInteger section = [newIndexPath section];

   [self performSelector: @selector(deselect:) withObject: tableView
              afterDelay: 0.1f];
   if (row != checkedRow || section != checkedSection) {
      [[Options sharedOptions]
         setSaveGameFile: [[[tableView cellForRowAtIndexPath: newIndexPath] textLabel] text]];
      [tableView reloadData];
      [gameDetailsController updateTableCells];
   }
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

if (editingStyle == UITableViewCellEditingStyleDelete) {
// Delete the row from the data source
[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
}
else if (editingStyle == UITableViewCellEditingStyleInsert) {
// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}
}
*/


 /*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


 /*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}


- (void)newFile:(id)sender {
   NSLog(@"new file");
   TypeFileNameController *tfnc = [[TypeFileNameController alloc]
                                     initWithSaveFileListController: self];
   [[self navigationController] pushViewController: tfnc animated: YES];
}


- (void)addFileName:(NSString *)aNewFileName {
   NSString *trimmedFileName =
      [aNewFileName stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceCharacterSet]];
   if (![trimmedFileName isEqualToString: @""]) {
      NSString *newFileName;
      if ([trimmedFileName hasSuffix: @".pgn"])
         newFileName = [NSString stringWithString: trimmedFileName];
      else
         newFileName = [NSString stringWithFormat: @"%@.pgn", trimmedFileName];
      [fileList addObject: newFileName];
      [fileList sortUsingSelector: @selector(compare:)];
      for (int i = 0; i < [fileList count]; i++)
         if ([[fileList objectAtIndex: i] isEqualToString: newFileName])
            checkedRow = i;
      [[Options sharedOptions] setSaveGameFile: newFileName];
      [gameDetailsController updateTableCells];
      [[self tableView] reloadData];

      // Create the file
      FILE *f =
         fopen([[PGN_DIRECTORY
                   stringByAppendingPathComponent: newFileName] UTF8String],
               "a");
      if (f != NULL) fclose(f);

   }
}




@end

