/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "LastMoveView.h"
#import "Options.h"

@implementation LastMoveView


- (id)initWithFrame:(CGRect)frame fromSq:(Square)fSq toSq:(Square)tSq {
   if (self = [super initWithFrame:frame]) {
      square1 = fSq;
      square2 = tSq;
      sqSize = frame.size.width / 8;
   }
   return self;
}


- (void)drawRect:(CGRect)rect {
   int i;
   Square s;
    //contorno amarelo em volta da casa selecionada
    
   for (i = 0, s = square1; i < 2; i++, s = square2) {
      int f = int(square_file(s)), r = 7 - int(square_rank(s));
       
       
      CGRect frame = CGRectMake(f * sqSize, r * sqSize, sqSize, sqSize);
//       [[[Options sharedOptions] highlightColor] set];
//       UIRectFrame(CGRectInset(frame, -1.0f, -1.0f));
//       [[[Options sharedOptions] highlightColor] set];
//       UIRectFrame(frame);
//       [[[Options sharedOptions] highlightColor] set];
//       UIRectFrame(CGRectInset(frame, 1.0f, 1.0f));
//       UIRectFrame(CGRectInset(frame, 2.0f, 2.0f));
//       UIRectFill(rect);
       [[UIColor colorWithRed:0.95 green:0.93 blue:0.29 alpha:.5] set];
//       CGContextFillRect(context, rect);
       UIRectFill(frame);

   }
}




@end
