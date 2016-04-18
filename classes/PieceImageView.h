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

#include "../Chess/square.h"

using namespace Chess;

@class BoardView;
@class GameController;

@interface PieceImageView : UIImageView {
   GameController *gameController;
   BoardView *boardView;
   Square square;
   CGRect oldFrame;
   CGPoint location;
   BOOL isBeingDragged;
   BOOL wasDraggedAwayFromSquare;
   float sqSize;
}

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, readonly) Square square;

- (id)initWithFrame:(CGRect)frame
     gameController:(GameController *)controller
          boardView:(BoardView *)bView;
- (void)moveToSquare:(Square)newSquare animate:(BOOL)animate;
- (void)moveToSquare:(Square)newSquare;
- (void)moveToSquareAndBack:(Square)newSquare;
- (void)simpleMoveToSquare:(Square)newSquare
                  duration:(float)duration
                   fromPly:(int)fromPly
                     toPly:(int)toPly
                currentPly:(int)currentPly;

@end
