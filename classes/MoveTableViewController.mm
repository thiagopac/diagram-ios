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

#import "BoardViewController.h"
#import "Game.h"
#import "MoveListCell.h"
#import "MoveTableViewController.h"


@implementation MoveTableViewController


- (id)initWithBoardViewController:(BoardViewController *)bvc game:(Game *)g {
   if ((self = [super initWithStyle: UITableViewStylePlain])) {
      boardViewController = bvc;
      game = g;
      moveList = [game moveList];
      selectedRow = -1; //[game currentMoveIndex];
   }
   return self;
}


- (void)loadView {
   [super loadView];
   [self setTitle: @"Move list"];
   [[self navigationItem]
      setLeftBarButtonItem: [[UIBarButtonItem alloc]
                                initWithTitle: @"Cancel"
                                        style: UIBarButtonItemStylePlain
                                       target: boardViewController
                                       action: @selector(moveListMenuCancelPressed)]];
   [[self navigationItem]
      setRightBarButtonItem: [[UIBarButtonItem alloc]
                                initWithTitle: @"Done"
                                        style: UIBarButtonItemStylePlain
                                       target: self
                                       action: @selector(donePressed)]];
}


/*
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
   if ([indexPath row] == selectedRow)
      [(MoveListCell *)cell showBoardForGame: game atPly: selectedRow];
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   return [moveList count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil || row == selectedRow || [(MoveListCell *)cell hasBoardPreview])
      cell = [[MoveListCell alloc] initWithStyle: UITableViewCellStyleDefault
                                  reuseIdentifier: @"cell"];
   NSString *move = (row < [moveList count])? [moveList objectAtIndex: row] : @"...";
   BOOL blackStarts = [game startPosition]->side_to_move() == BLACK;
   int moveNumber = (int)(blackStarts? (row + 3) / 2 : (row + 2) / 2);
   if ((row + blackStarts) % 2 == 0) {// White move
      [[(MoveListCell *)cell whiteMoveText]
          setText: [NSString stringWithFormat: @"   %d.    %@",
                             moveNumber, move]];
      [[(MoveListCell *)cell blackMoveText] setText: @""];
   }
   else {
      if (row == 0)
         [[(MoveListCell *)cell whiteMoveText]
            setText: [NSString stringWithFormat: @"   %d.    ...",
                               moveNumber]];
      else
         [[(MoveListCell *)cell whiteMoveText] setText: @""];
      [[(MoveListCell *)cell blackMoveText]
          setText: [NSString stringWithFormat: @"      %@", move]];
   }
   if ([indexPath row] == selectedRow)
      [(MoveListCell *)cell showBoardForGame: game atPly: selectedRow];
   return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (selectedRow != [indexPath row]) {
      [(MoveListCell *)[tableView cellForRowAtIndexPath:
                                     [NSIndexPath indexPathForRow: selectedRow
                                                        inSection: 0]]
          removeBoardForGame: game atPly: selectedRow];
      selectedRow = (int)[indexPath row];
      [(MoveListCell *)[tableView cellForRowAtIndexPath: indexPath]
          showBoardForGame: game atPly: selectedRow];
      [tableView beginUpdates];
      [tableView endUpdates];
   }
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   if ([indexPath row] == selectedRow)
      return 0.5f * tableView.bounds.size.width;
      //return 161.0f;
   else
      return 42.0f;
}


/*
- (void)viewDidLoad {
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow: selectedRow
                                               inSection: 0];
   [[self tableView] selectRowAtIndexPath: indexPath
                                 animated: YES
                           scrollPosition: UITableViewScrollPositionTop];
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)donePressed {
   [boardViewController moveListMenuDonePressed: selectedRow];
}




@end
