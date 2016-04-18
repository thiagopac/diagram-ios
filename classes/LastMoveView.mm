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
