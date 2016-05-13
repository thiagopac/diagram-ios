/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import <UIKit/UIKit.h>

#include "../Chess/position.h"

using namespace Chess;

@class Game;

@interface BoardPreview : UIView {
   Position pos;
   float sqSize;
   UIColor *darkSquareColor, *lightSquareColor;
   UIImage *darkSquareImage, *lightSquareImage;
   UIImage *pieceImages[16];
}

- (id)initWithFrame:(CGRect)frame game:(Game *)game ply:(int)ply;

@end
