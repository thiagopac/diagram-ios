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

#import "BoardViewController.h"
#import "GameListController.h"
#import "LoadFileListController.h"
#import "Options.h"
#import "PGN.h"

@implementation LoadFileListController

@synthesize boardViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      boardViewController = bvc;
      [self setTitle: @"Game files"];
      fileList =
         (NSMutableArray *)
               [[[NSFileManager defaultManager]
                     contentsOfDirectoryAtPath:PGN_DIRECTORY
                                         error:NULL]
                     pathsMatchingExtensions:@[@"pgn"]];

      // It turns out that pathsForResourcesOfType:inDirectory: returns paths
      // even for deleted resources, so we'll have to filter them out manually:
      NSArray *builtins = [[NSBundle mainBundle] pathsForResourcesOfType: @"pgn"
                                                             inDirectory: nil];
      builtinFileList = [[NSMutableArray alloc] init];
      for (NSString *filename in builtins)
         if ([[NSFileManager defaultManager] fileExistsAtPath: filename])
            [builtinFileList addObject: filename];
   }
   return self;
}


- (void)loadView {
   [super loadView];
   [[self navigationItem]
      setLeftBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle: @"Cancel"
                                       style: UIBarButtonItemStylePlain
                                      target: boardViewController
                                      action: @selector(loadMenuCancelPressed)]];
   [[self navigationItem] setRightBarButtonItem: [self editButtonItem]];
   firstAppearance = true;
}


- (void)viewDidAppear:(BOOL)animated {
   if (!firstAppearance) return;
   firstAppearance = false;
   
   NSString *filename = [[Options sharedOptions] loadGameFile];

   if (![filename isEqualToString: @""]) {
      // HACK: Decide whether this is a built-in, readonly file by looking
      // at the second last component of the pathname.
      NSArray *pathnameComponents =[filename componentsSeparatedByString: @"/"];
      NSUInteger count = [pathnameComponents count];
      BOOL builtin = ![pathnameComponents[count - 2] isEqualToString:@"Documents"];
      NSUInteger section = builtin? 1 : 0;
      NSUInteger row = builtin?
      [builtinFileList indexOfObject: filename] : [fileList indexOfObject: [pathnameComponents lastObject]];
      if (row == NSNotFound)
         // Shouldn't be possible
         return;
      
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow: row inSection: section];
      [[self tableView] selectRowAtIndexPath: indexPath
                                    animated: NO
                              scrollPosition: UITableViewScrollPositionMiddle];
      // It is hard to believe that manually calling tableView:didSelectRowAtIndexPath
      // is the right way to automatically push on to the next view controller, but
      // I can't find a better way to do it.
      [self tableView: [self tableView] didSelectRowAtIndexPath: indexPath];
   }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   return (section == 0)? [fileList count] : [builtinFileList count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   return (section == 0)? @"Your game files" : @"Built-in game files";
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   NSInteger section = [indexPath section];

   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"cell"];
   }
   if (section == 0)
      [[cell textLabel] setText: [fileList[row]
                                  stringByReplacingOccurrencesOfString: @".pgn"
                                  withString: @""]];
   else {
      NSString *filename = [[[builtinFileList[row]
                              componentsSeparatedByString: @"/"]
                             lastObject]
                            stringByReplacingOccurrencesOfString: @".pgn"
                            withString: @""];
      [[cell textLabel]
       setText: filename];
   }
   [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
   (NSIndexPath *)newIndexPath {
   NSInteger row = [newIndexPath row];
   NSInteger section = [newIndexPath section];
   GameListController *glc;
   
   if (section == 0)
      glc = [[GameListController alloc]
             initWithLoadFileListController: self
                                   filename:fileList[row]
                                 isReadonly: NO];
   else
      glc = [[GameListController alloc]
              initWithLoadFileListController: self
                                    filename:builtinFileList[row]
                                  isReadonly: YES];
   
   [[self navigationController] pushViewController: glc animated: YES];
   [self performSelector: @selector(deselect:) withObject: tableView
              afterDelay: 0.1f];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   return [indexPath section] == 0;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
   return UITableViewCellEditingStyleDelete;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
   [super setEditing: editing animated: animated];
   [[self tableView] setEditing: editing animated: animated];
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger section = [indexPath section], row = [indexPath row];
   NSString *filename;
   if (section == 0) {
      filename = [PGN_DIRECTORY stringByAppendingPathComponent:fileList[row]];
   } else {
      filename = builtinFileList[row];
   }
   [[NSFileManager defaultManager] removeItemAtPath: filename error: nil];
   [((section == 0)? fileList : builtinFileList) removeObjectAtIndex: row];
   [tableView deleteRowsAtIndexPaths: @[indexPath]
                    withRowAnimation: UITableViewRowAnimationAutomatic];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the specified item to be editable.
return YES;
}
*/


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


- (void)updateTableCells {
   fileList =
      (NSMutableArray *)
            [[[NSFileManager defaultManager]
                  contentsOfDirectoryAtPath:PGN_DIRECTORY error:NULL]
                  pathsMatchingExtensions:@[@"pgn"]];
   [[self tableView] reloadData];
}


- (void)removeItemWithFilename:(NSString *)filename {
   NSUInteger index = [fileList indexOfObject: filename];
   if (index == NSNotFound)
      NSLog(@"tried to remove item named %@, but couldn't find it in fileList!",
            filename);
   else {
      [fileList removeObjectAtIndex: index];
      [[self tableView] reloadData];
   }
}




@end
