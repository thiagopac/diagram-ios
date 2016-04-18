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

#import <UIKit/UIKit.h>

@class BoardViewController;

@interface OptionsViewController : UITableViewController {
   BoardViewController *__weak boardViewController;
}

@property (weak, nonatomic, readonly) BoardViewController *boardViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc;
- (void)deselect:(UITableView *)tableView;
- (void)toggleShowAnalysis:(id)sender;
- (void)toggleShowBookMoves:(id)sender;
- (void)toggleShowLegalMoves:(id)sender;
- (void)toggleShowCoordinates:(id)sender;
- (void)toggleShowAnalysisArrows:(id)sender;
- (void)togglePermanentBrain:(id)sender;
- (void)toggleFigurines:(id)sender;
- (void)toggleSound:(id)sender;
- (void)updateTableCells;

@end
