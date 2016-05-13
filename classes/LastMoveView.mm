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

   for (i = 0, s = square1; i < 2; i++, s = square2) {
      int f = int(square_file(s)), r = 7 - int(square_rank(s));
      CGRect frame = CGRectMake(f * sqSize, r * sqSize, sqSize, sqSize);
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         [[[Options sharedOptions] brightHighlightColor] set];
         UIRectFrame(CGRectInset(frame, -1.0f, -1.0f));
         [[[Options sharedOptions] highlightColor] set];
         UIRectFrame(frame);
         UIRectFrame(CGRectInset(frame, 1.0f, 1.0f));
         [[[Options sharedOptions] brightHighlightColor] set];
         UIRectFrame(CGRectInset(frame, 2.0f, 2.0f));
      } else {
         [[[Options sharedOptions] brightHighlightColor] set];
         UIRectFrame(CGRectInset(frame, -1.0f, -1.0f));
         [[[Options sharedOptions] highlightColor] set];
         UIRectFrame(frame);
         [[[Options sharedOptions] brightHighlightColor] set];
         UIRectFrame(CGRectInset(frame, 1.0f, 1.0f));
      }
   }
}




@end
