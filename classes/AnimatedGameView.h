/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class Game;

@interface AnimatedGameView : UIView {
   Game *game;
   float sqSize;
   UIColor *darkSquareColor, *lightSquareColor;
   UIImage *darkSquareImage, *lightSquareImage;
   UIImage *pieceImages[16];
   UIImageView *pieceViews[64];
   BOOL animationShouldStop;
}

- (id)initWithGame:(Game *)g frame:(CGRect)rect;
- (void)startAnimation;
- (void)stopAnimation;

@end
