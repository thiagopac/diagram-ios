/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
