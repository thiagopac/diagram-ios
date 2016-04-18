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

@class ArrowView;
@class CoordinatesView;
@class GameController;
@class HighlightedSquaresView;
@class LastMoveView;
@class SelectedSquareView;

@interface BoardView : UIView {
   UIColor *darkSquareColor, *lightSquareColor;
   UIImage *darkSquareImage, *lightSquareImage;
   GameController *__weak gameController;
   HighlightedSquaresView *highlightedSquaresView;
   Square highlightedSquares[32];
   SelectedSquareView *selectedSquareView;
   Square fromSquare, selectedSquare;
   LastMoveView *lastMoveView;
   ArrowView *arrowView;
   float sqSize;
   CoordinatesView *coordinatesView;
}

@property (nonatomic, weak) GameController *gameController;
@property (nonatomic, readonly) Square fromSquare;
@property (nonatomic, readonly) float sqSize;

- (Square)squareAtPoint:(CGPoint)point;
- (CGPoint)originOfSquare:(Square)sq;
- (CGRect)rectForSquare:(Square)sq;
- (void)highlightSquares:(Square *)sqs;
- (void)stopHighlighting;
- (void)selectionMovedToPoint:(CGPoint)sq;
- (void)colorsChanged:(NSNotification *)aNotification;
- (void)showLastMoveWithFrom:(Square)s1 to:(Square)s2;
- (void)hideLastMove;
- (void)showArrowFrom:(Square)s1 to:(Square)s2;
- (void)hideArrow;
- (void)bringArrowToFront;
- (void)pieceTouchedAtSquare:(Square)s;
- (void)setRotated:(BOOL)rotated;
- (void)showCoordinates:(BOOL)show;
- (void)showCoordinatesChanged :(NSNotification *)aNotification;
 
@end
