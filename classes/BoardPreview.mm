/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski

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

#import "BoardPreview.h"
#import "Game.h"
#import "Options.h"

@implementation BoardPreview

- (id)initWithFrame:(CGRect)frame game:(Game *)game ply:(int)ply {
   self = [super initWithFrame:frame];
   if (self) {
      darkSquareColor = [[Options sharedOptions] darkSquareColor];
      lightSquareColor = [[Options sharedOptions] lightSquareColor];
      darkSquareImage = [[Options sharedOptions] darkSquareImage];
      lightSquareImage = [[Options sharedOptions] lightSquareImage];
      sqSize = frame.size.width / 8;

      static NSString *pieceImageNames[16] = {
         nil, @"WPawn", @"WKnight", @"WBishop", @"WRook", @"WQueen", @"WKing", nil,
         nil, @"BPawn", @"BKnight", @"BBishop", @"BRook", @"BQueen", @"BKing", nil
      };
      NSString *pieceSet = [[Options sharedOptions] pieceSet];
      for (Piece p = WP; p <= BK; p++) {
         if (piece_is_ok(p)) {
            pieceImages[p] =
               [UIImage imageNamed: [NSString stringWithFormat: @"%@%@.png",
                                      pieceSet, pieceImageNames[p]]];
         }
         else
            pieceImages[p] = nil;
      }

      pos = Position(*[game startPosition]);
      if (ply > 0) {
         UndoInfo u;
         int i = 0;
         for (ChessMove *move in [game moves]) {
            pos.do_move([move move], u);
            i++;
            if (i >= ply) break;
         }
      }
   }
   return self;
}

- (void)drawRect:(CGRect)rect {
   int i, j;
   for (i = 0; i < 8; i++)
      for (j = 0; j < 8; j++) {
         CGRect r = CGRectMake(i * sqSize, j*sqSize, sqSize, sqSize);
         if (darkSquareImage && lightSquareImage) {
            [(((i + j) & 1)? darkSquareImage : lightSquareImage)
             drawInRect: r];
         }
         else {
            [(((i + j) & 1)? darkSquareColor : lightSquareColor) set];
            UIRectFill(CGRectMake(i*sqSize, j*sqSize, sqSize, sqSize));
         }
      }

   CGRect r = CGRectMake(0.0f, 0.0f, sqSize, sqSize);
   for (Square s = SQ_A1; s <= SQ_H8; s++) {
      Piece p = pos.piece_on(s);
      if (p != EMPTY) {
         r.origin = CGPointMake((int(s)%8) * sqSize, (7-int(s)/8) * sqSize);
         [pieceImages[p] drawInRect: r];
      }
   }
}

- (void)dealloc {
   for (Piece p = WP; p <= BK; p++)
      ;
}


@end
