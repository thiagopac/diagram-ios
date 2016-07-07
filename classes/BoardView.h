/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#include "../Chess/square.h"

using namespace Chess;

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
- (void)pieceTouchedAtSquare:(Square)s;
- (void)setRotated:(BOOL)rotated;
- (void)showCoordinates:(BOOL)show;
- (void)showCoordinatesChanged :(NSNotification *)aNotification;
 
@end
