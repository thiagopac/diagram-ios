/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "ArrowView.h"
#import "Options.h"


@implementation ArrowView

- (id)initWithFrame:(CGRect)frame fromSq:(Square)fSq toSq:(Square)tSq {
   if (self = [super initWithFrame:frame]) {
      square1 = fSq;
      square2 = tSq;
      sqSize = frame.size.width / 8;
   }
   return self;
}


- (void)drawRect:(CGRect)rect {
   float x1 = float(square_file(square1)) * sqSize + 0.5f * sqSize;
   float y1 = (7.0f - float(square_rank(square1))) * sqSize + 0.5f * sqSize;
   float x2 = float(square_file(square2)) * sqSize + 0.5f * sqSize;
   float y2 = (7.0f - float(square_rank(square2))) * sqSize + 0.5f * sqSize;
   float dx = x2 - x1, dy = y2 - y1;
   float length = (float)sqrt(dx * dx + dy * dy);
   double alpha = atan(dy / dx);
   float width = sqSize / 10.0f;
   float xx = x1 + (x2 - x1) *  (length - 4 * width) / length;
   float yy = y1 + (y2 - y1) *  (length - 4 * width) / length;
   float c = (float)cos(0.5f * M_PI - alpha);
   float s = (float)sin(0.5f * M_PI - alpha);
   CGPoint points[] = {
      CGPointMake(x1 + 0.5f * width * c, y1 - 0.5f * width * s),
      CGPointMake(x1 - 0.5f * width * c, y1 + 0.5f * width * s),
      CGPointMake(xx - 0.5f * width * c, yy + 0.5f * width * s),
      CGPointMake(xx - 1.5f * width * c, yy + 1.5f * width * s),
      CGPointMake(x2, y2),
      CGPointMake(xx + 1.5f * width * c, yy - 1.5f * width * s),
      CGPointMake(xx + 0.5f * width * c, yy - 0.5f * width * s),
   };
   UIBezierPath *path = [UIBezierPath bezierPath];
   [[Options sharedOptions].arrowColor setFill];
   [[Options sharedOptions].arrowOutlineColor setStroke];
   path.lineWidth = sqSize / 40.0f;
   [path moveToPoint: points[6]];
   for (int i = 0; i < 7; i++) {
      [path addLineToPoint: points[i]];
   }
   [path fill];
   [path stroke];
}


@end