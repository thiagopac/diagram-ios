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
#import "LevelViewController.h"
#import "Options.h"


@implementation LevelViewController

- (id)initWithBoardViewController:(BoardViewController *)bvc {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      [self setTitle: @"Level/Game Mode"];
      boardViewController = bvc;
   }
   return self;

}


- (void)loadView {
   [super loadView];
   [[self navigationItem] setRightBarButtonItem:
                             [[UIBarButtonItem alloc]
                                 initWithTitle: @"Done"
                                         style: UIBarButtonItemStylePlain
                                        target: boardViewController
                                        action: @selector(levelsMenuDonePressed)]];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

   switch(section) {

   case 0: // Game mode
      return 4;
   case 1: // Level
      return 13; // 14;
   default:
      assert(NO);
   }
   return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   NSInteger section = [indexPath section];

   UITableViewCell *cell =
      [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil)
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"cell"];
   if (section == 0) {
      [cell setAccessoryType:
               (([[Options sharedOptions] gameMode] == (GameMode)row)?
                UITableViewCellAccessoryCheckmark :
                UITableViewCellAccessoryNone)];
      if (row == 0)
         [[cell textLabel] setText: @"Computer plays black"];
      else if (row == 1)
         [[cell textLabel] setText: @"Computer plays white"];
      else if (row == 2)
         [[cell textLabel] setText: @"Continuous analysis"];
      else if (row == 3)
         [[cell textLabel] setText: @"Two player"];
   }
   else if (section == 1) {
      [cell setAccessoryType:
               (([[Options sharedOptions] gameLevel] == (GameLevel)row)?
                UITableViewCellAccessoryCheckmark :
                UITableViewCellAccessoryNone)];
      if (row == 0)
         [[cell textLabel] setText: @"Game in 2"];
      else if (row == 1)
         [[cell textLabel] setText: @"Game in 2+1"];
      else if (row == 2)
         [[cell textLabel] setText: @"Game in 5"];
      else if (row == 3)
         [[cell textLabel] setText: @"Game in 5+2"];
      else if (row == 4)
         [[cell textLabel] setText: @"Game in 15"];
      else if (row == 5)
         [[cell textLabel] setText: @"Game in 15+5"];
      else if (row == 6)
         [[cell textLabel] setText: @"Game in 30"];
      else if (row == 7)
         [[cell textLabel] setText: @"Game in 30+5"];
      else if (row == 8)
         [[cell textLabel] setText: @"1 second/move"];
      else if (row == 9)
         [[cell textLabel] setText: @"2 seconds/move"];
      else if (row == 10)
         [[cell textLabel] setText: @"5 seconds/move"];
      else if (row == 11)
         [[cell textLabel] setText: @"10 seconds/move"];
      else if (row == 12)
         [[cell textLabel] setText: @"30 seconds/move"];
      /*
      else if (row == 13)
         [[cell textLabel] setText: @"Custom level"];
      */
   }
   return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:
   (NSIndexPath *)newIndexPath {
   NSInteger row = [newIndexPath row];
   NSInteger section = [newIndexPath section];

   [self performSelector:@selector(deselect:) withObject: tableView
              afterDelay: 0.1f];
   if (section == 0) { // Game mode
      GameMode newGameMode = (GameMode)row;
      GameMode oldGameMode = [[Options sharedOptions] gameMode];

      if (newGameMode != oldGameMode) {
         [[Options sharedOptions] setGameMode: newGameMode];
         [boardViewController gameModeWasChanged];
         [[tableView cellForRowAtIndexPath:
                        [NSIndexPath indexPathForRow:(NSUInteger)oldGameMode
                                           inSection: 0]]
            setAccessoryType: UITableViewCellAccessoryNone];
         [[tableView cellForRowAtIndexPath: newIndexPath]
            setAccessoryType: UITableViewCellAccessoryCheckmark];
      }
   }
   else if (section == 1) { // Level
      GameLevel newGameLevel = (GameLevel)row;
      GameLevel oldGameLevel = [[Options sharedOptions] gameLevel];

      if (newGameLevel != oldGameLevel) {
         [[Options sharedOptions] setGameLevel: newGameLevel];
         [boardViewController levelWasChanged];
         [[tableView cellForRowAtIndexPath:
                        [NSIndexPath indexPathForRow:(NSUInteger)oldGameLevel
                                           inSection: 1]]
            setAccessoryType: UITableViewCellAccessoryNone];
         [[tableView cellForRowAtIndexPath: newIndexPath]
            setAccessoryType: UITableViewCellAccessoryCheckmark];
      }
   }
}


- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}




@end
