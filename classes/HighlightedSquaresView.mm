/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "HighlightedSquaresView.h"
#import "Options.h"


@implementation HighlightedSquaresView

@dynamic selectedSquare;

- (id)initWithFrame:(CGRect)frame squares:(Square *)sqs
ignoreShowLegalMovesOption:(BOOL)ignoreShowLegalMovesOption {
   if (self = [super initWithFrame: frame]) {
      int i;
      for (i = 0; sqs[i] != SQ_NONE; i++)
         squares[i] = sqs[i];
      squares[i] = SQ_NONE;
      selectedSquare = SQ_NONE;
      sqSize = frame.size.width / 8;
      shouldIgnoreShowLegalMovesOption = ignoreShowLegalMovesOption;
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame squares:(Square *)sqs {
   return [self initWithFrame: frame
                      squares: sqs
   ignoreShowLegalMovesOption: NO];
}

/// drawRect: simply draws little ellipses in the center of each square.
/// Perhaps we should switch to something prettier later.

- (void)drawRect:(CGRect)rect {
   if (shouldIgnoreShowLegalMovesOption ||
       [[Options sharedOptions] showLegalMoves]) {
      CGContextRef context = UIGraphicsGetCurrentContext();
      CGContextSetLineWidth(context, sqSize / 20.0f);
      for (int i = 0; squares[i] != SQ_NONE; i++) {
         int f = int(square_file(squares[i])), r = 7-int(square_rank(squares[i]));

         CGRect rec = CGRectInset(CGRectMake(f*sqSize, r*sqSize, sqSize, sqSize),
                                   0.35f*sqSize, 0.35f*sqSize);
         [[[Options sharedOptions] brightHighlightColor] set];
         CGContextSetLineWidth(context, sqSize / 5.0f);
         CGContextAddEllipseInRect(context, rec);
         CGContextStrokePath(context);
         [[[Options sharedOptions] highlightColor] set];
         CGContextSetLineWidth(context, sqSize / 20.0f);
         CGContextAddEllipseInRect(context, rec);
#pragma RETIREI O SOMBREAMENTO DAS VIEWS DESENHADAS NAS CASAS DE MOVIMENTOS POSSÍVEIS DE CADA PEÇA
//         CGContextStrokePath(context);
      }

      if (selectedSquare != SQ_NONE) {
         int f = int(square_file(selectedSquare));
         int r = 7-int(square_rank(selectedSquare));
         CGContextSetLineWidth(context, 1.0f);
         CGRect squareRect = CGRectMake(f*sqSize, r*sqSize, sqSize, sqSize);
         [[[Options sharedOptions] brightHighlightColor] set];
         UIRectFrame(squareRect);
         [[[Options sharedOptions] highlightColor] set];
         UIRectFrame(CGRectInset(squareRect, 1.0f, 1.0f));
         [[[Options sharedOptions] brightHighlightColor] set];
         UIRectFrame(CGRectInset(squareRect, 2.0f, 2.0f));
      }
   }
}


- (Square)selectedSquare {
   return selectedSquare;
}


- (void)setSelectedSquare:(Square)s {
   selectedSquare = s;
   [self setNeedsDisplay];
}




@end
