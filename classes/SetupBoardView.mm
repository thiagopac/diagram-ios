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

#import "HighlightedSquaresView.h"
#import "Options.h"
#import "SelectedPieceView.h"
#import "SelectedSquareView.h"
#import "SetupBoardView.h"
#import "SetupViewController.h"

#import "position.h"


@implementation SetupBoardView

@synthesize selectedPieceView;

- (id)initWithController:(id)c
                   frame:(CGRect)frame
                     fen:(NSString *)fen
                   phase:(SetupPhase)aPhase {
   /*
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      frame = CGRectMake(0, 0, 320, 320);
    */
   if (self = [super initWithFrame: frame]) {
      sqSize = frame.size.width / 8.0f;
      NSLog(@"sqSize is %f", sqSize);
      controller = c;
      startFen = fen;
      phase = aPhase;
      darkSquareColor = [[Options sharedOptions] darkSquareColor];
      lightSquareColor = [[Options sharedOptions] lightSquareColor];
      darkSquareImage = [[Options sharedOptions] darkSquareImage];
      lightSquareImage = [[Options sharedOptions] lightSquareImage];
      pieceViews = [[NSMutableArray alloc] init];

      static NSString *pieceImageNames[16] = {
         nil, @"WPawn", @"WKnight", @"WBishop", @"WRook",
         @"WQueen", @"WKing", nil, nil, @"BPawn", @"BKnight",
         @"BBishop", @"BRook", @"BQueen", @"BKing", nil
      };
      NSString *pieceSet = [[Options sharedOptions] pieceSet];
      for (Piece p = WP; p <= BK; p++) {
         if (piece_is_ok(p))
            pieceImages[p] =
               [UIImage imageNamed: [NSString stringWithFormat: @"%@%@.png",
                                               pieceSet,
                                               pieceImageNames[p]]];
         else
            pieceImages[p] = nil;
      }

      for (int i = 0; i < 2; i++)
         for (int j = 0; j < 16; j++)
            bitboards[i][j] = 0ULL;

      Position p([fen UTF8String]);
      for (Square s = SQ_A1; s <= SQ_H8; s++) {
         board[s] = EMPTY;
         if (p.square_is_occupied(s))
            [self putPiece: p.piece_on(s) onSquare: s];
      }
      selectedSquare = SQ_NONE;

      if (phase == PHASE_EDIT_EP) {
         [self epCandidateSquares: epSquares];
         CGRect rect = [self frame];
         rect.origin = CGPointMake(0.0f, 0.0f);
         highlightedSquaresView =
            [[HighlightedSquaresView alloc] initWithFrame: rect squares: epSquares
                               ignoreShowLegalMovesOption: YES];
         [highlightedSquaresView setOpaque: NO];
         [self addSubview: highlightedSquaresView];
      }
      else highlightedSquaresView = nil;
   }
   return self;
}


- (void)drawRect:(CGRect)rect {
   int i, j;
   for (i = 0; i < 8; i++)
      for (j = 0; j < 8; j++) {
         if (darkSquareImage && lightSquareImage) {
            [(((i + j) & 1)? darkSquareImage : lightSquareImage)
                  drawInRect: CGRectMake(i * sqSize, j * sqSize, sqSize, sqSize)];
         } else {
            [(((i + j) & 1)? darkSquareColor : lightSquareColor) set];
            UIRectFill(CGRectMake(i*sqSize, j*sqSize, sqSize, sqSize));
         }
      }
}


- (void)putPiece:(Piece)p onSquare:(Square)s {
   if (board[s] == EMPTY) {
      board[s] = p;
      set_bit(&bitboards[color_of_piece(p)][type_of_piece(p)], s);
      set_bit(&bitboards[0][0], s);
      UIImageView *iv =
         [[UIImageView alloc]
            initWithFrame: CGRectMake(int(s)%8 * sqSize, (7-int(s)/8) * sqSize,
                                      sqSize, sqSize)];
      [iv setImage: pieceImages[p]];
      [self addSubview: iv];
      [pieceViews addObject: iv];
   }
}


- (void)removePieceOnSquare:(Square)s {
   assert(phase == PHASE_EDIT_BOARD);
   Piece p = board[s];
   clear_bit(&bitboards[color_of_piece(p)][type_of_piece(p)], s);
   clear_bit(&bitboards[0][0], s);
   board[s] = EMPTY;
}


- (void)clear {
   if (phase == PHASE_EDIT_BOARD) {
      for (UIImageView *iv in pieceViews)
         [iv removeFromSuperview];
      for (Square s = SQ_A1; s <= SQ_H8; s++)
         board[s] = EMPTY;
      for (int i = 0; i < 2; i++)
         for (int j = 0; j < 16; j++)
            bitboards[i][j] = 0ULL;
      [pieceViews removeAllObjects];
      [(SetupViewController *)controller disableDoneButton];
   }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   if (phase == PHASE_EDIT_BOARD) {
      CGPoint pt = [[touches anyObject] locationInView: self];
      int row = (int)(pt.y / sqSize);
      int column = (int)(pt.x / sqSize);
      selectedSquare = make_square(File(column), Rank(7-row));
      selectedSquareView =
         [[SelectedSquareView alloc]
            initWithFrame: CGRectMake(0.0f, 0.0f, 5.0f*sqSize, 5.0f*sqSize)];
      [selectedSquareView moveToPoint:
                             CGPointMake((column - 2) * sqSize, (row - 2) * sqSize)];
      [selectedSquareView setOpaque: NO];
      [self addSubview: selectedSquareView];
   }
   else if (phase == PHASE_EDIT_EP) {
      CGPoint pt = [[touches anyObject] locationInView: self];
      int row = (int)(pt.y / sqSize);
      int column = (int)(pt.x / sqSize);
      selectedSquare = make_square(File(column), Rank(7-row));
      int i;

      selectedSquareView =
         [[SelectedSquareView alloc]
            initWithFrame: CGRectMake(0.0f, 0.0f, 5.0f*sqSize, 5.0f*sqSize)];
      [selectedSquareView setOpaque: NO];
      [selectedSquareView hide];
      [self addSubview: selectedSquareView];
      for (i = 0; epSquares[i] != SQ_NONE; i++)
         if (epSquares[i] == selectedSquare) {
            [selectedSquareView moveToPoint:
                  CGPointMake((column - 2) * sqSize, (row - 2) * sqSize)];
            return;
         }
      selectedSquare = SQ_NONE;
   }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   if (phase == PHASE_EDIT_BOARD && selectedSquare != SQ_NONE) {
      CGPoint pt = [[touches anyObject] locationInView: self];
      if (pt.x >= 8*sqSize || pt.x <= 0 || pt.y >= 8*sqSize || pt.y <= 0) {
         [selectedSquareView removeFromSuperview];
         selectedSquare = SQ_NONE;
         return;
      }
      int row = (int)(pt.y / sqSize);
      int column = (int)(pt.x / sqSize);

      Square s = make_square(File(column), Rank(7-row));
      if (s != selectedSquare) {
         selectedSquare = s;
         [selectedSquareView moveToPoint:
               CGPointMake((column - 2) * sqSize, (row - 2) * sqSize)];
      }
   }
   else if (phase == PHASE_EDIT_EP) {
      CGPoint pt = [[touches anyObject] locationInView: self];
      int row = (int)(pt.y / sqSize);
      int column = (int)(pt.x / sqSize);
      Square s = make_square(File(column), Rank(7-row));
      if (s != selectedSquare) {
         int i;
         for (i = 0; epSquares[i] != SQ_NONE; i++)
            if (epSquares[i] == s) {
               [selectedSquareView moveToPoint:
                     CGPointMake((column - 2) * sqSize, (row - 2) * sqSize)];
               selectedSquare = s;
               return;
            }
         [selectedSquareView hide];
         selectedSquare = SQ_NONE;
      }
   }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   if (phase == PHASE_EDIT_BOARD && selectedSquare != SQ_NONE) {
      if (board[selectedSquare] == EMPTY) {
         if (type_of_piece([selectedPieceView selectedPiece]) != PAWN
             || (square_rank(selectedSquare) != RANK_1 &&
                 square_rank(selectedSquare) != RANK_8))
            [self putPiece: [selectedPieceView selectedPiece]
                  onSquare: selectedSquare];
      }
      else {
         [self removePieceOnSquare: selectedSquare];
         // Find the piece view at the current square, and remove it.
         CGFloat x = (int)square_file(selectedSquare) * sqSize;
         CGFloat y = (int)(7 - square_rank(selectedSquare)) * sqSize;
         CGRect r;
         for (int i = 0; i < [pieceViews count]; i++) {
            r = [[pieceViews objectAtIndex: i] frame];
            if (r.origin.x == x && r.origin.y == y) {
               [[pieceViews objectAtIndex: i] removeFromSuperview];
               [pieceViews removeObjectAtIndex: i];
               break;
            }
         }
      }
      [selectedSquareView removeFromSuperview];

      int whiteIsInCheck = [self whiteIsInCheck];
      int blackIsInCheck = [self blackIsInCheck];
      if ([self pieceCountsOK]
          && !(whiteIsInCheck && blackIsInCheck)
          && whiteIsInCheck <= 2 && blackIsInCheck <= 2)
         [(SetupViewController *)controller enableDoneButton];
      else
         [(SetupViewController *)controller disableDoneButton];

      NSLog(@"%@", [self fen]);
   }
   else if (phase == PHASE_EDIT_EP) {
      [selectedSquareView removeFromSuperview];
      [highlightedSquaresView setSelectedSquare: selectedSquare];
   }
}


- (BOOL)pieceCountsOK {
   if (count_1s(bitboards[WHITE][KING]) != 1)
      return NO;
   if (count_1s(bitboards[BLACK][KING]) != 1)
      return NO;
   if (count_1s(bitboards[WHITE][QUEEN]) > 9)
      return NO;
   if (count_1s(bitboards[BLACK][QUEEN]) > 9)
      return NO;
   if (count_1s(bitboards[WHITE][ROOK]) > 10)
      return NO;
   if (count_1s(bitboards[BLACK][ROOK]) > 10)
      return NO;
   if (count_1s(bitboards[WHITE][BISHOP]) > 10)
      return NO;
   if (count_1s(bitboards[BLACK][BISHOP]) > 10)
      return NO;
   if (count_1s(bitboards[WHITE][KNIGHT]) > 10)
      return NO;
   if (count_1s(bitboards[BLACK][KNIGHT]) > 10)
      return NO;
   if (count_1s(bitboards[WHITE][PAWN]) > 8)
      return NO;
   if (count_1s(bitboards[BLACK][PAWN]) > 8)
      return NO;
   return YES;
}


- (int)whiteIsInCheck {
   Bitboard b = bitboards[WHITE][KING];
   if (b) {
      Square ksq = first_1(b);
      return count_1s((StepAttackBB[WP][ksq] & bitboards[BLACK][PAWN])
                      | (StepAttackBB[KNIGHT][ksq] & bitboards[BLACK][KNIGHT])
                      | (StepAttackBB[KING][ksq] & bitboards[BLACK][KING])
                      | (bishop_attacks_bb(ksq, bitboards[0][0])
                         & (bitboards[BLACK][BISHOP] | bitboards[BLACK][QUEEN]))
                      | (rook_attacks_bb(ksq, bitboards[0][0])
                         & (bitboards[BLACK][ROOK] | bitboards[BLACK][QUEEN])));
   }
   else return 0;
}


- (int)blackIsInCheck {
   Bitboard b = bitboards[BLACK][KING];
   if (b) {
      Square ksq = first_1(b);
      return count_1s((StepAttackBB[BP][ksq] & bitboards[WHITE][PAWN])
                      | (StepAttackBB[KNIGHT][ksq] & bitboards[WHITE][KNIGHT])
                      | (StepAttackBB[KING][ksq] & bitboards[WHITE][KING])
                      | (bishop_attacks_bb(ksq, bitboards[0][0])
                         & (bitboards[WHITE][BISHOP] | bitboards[WHITE][QUEEN]))
                      | (rook_attacks_bb(ksq, bitboards[0][0])
                         & (bitboards[WHITE][ROOK] | bitboards[WHITE][QUEEN])));
   }
   else return 0;
}


- (NSString *)boardString {
   char pieceLetters[] = " PNBRQK  pnbrqk";
   char buf[100];
   int skip, i = 0;

   for (Rank rank = RANK_8; rank >= RANK_1; rank--) {
      skip = 0;
      for (File file = FILE_A; file <= FILE_H; file++) {
         Square square = make_square(file, rank);
         if (board[square] != EMPTY) {
            if (skip > 0) buf[i++] = (char)skip + '0';
            buf[i++] = pieceLetters[board[square]];
            skip = 0;
         }
         else skip++;
      }
      if (skip > 0) buf[i++] = (char)skip + '0';
      buf[i++] = (rank > RANK_1)? '/' : ' ';
   }
   buf[i] = '\0';
   return [NSString stringWithUTF8String: buf];
}


- (NSString *)maybeCastleString {
   BOOL wOO=NO, wOOO=NO, bOO=NO, bOOO=NO;
   if (board[SQ_E1] == WK) {
      if (board[SQ_A1] == WR) wOOO = YES;
      if (board[SQ_H1] == WR) wOO = YES;
   }
   if (board[SQ_E8] == BK) {
      if (board[SQ_A8] == BR) bOOO = YES;
      if (board[SQ_H8] == BR) bOO = YES;
   }
   if (wOO || wOOO || bOO || bOOO) {
      char str[8];
      int i = 0;
      if (wOO) str[i++] = 'K';
      if (wOOO) str[i++] = 'Q';
      if (bOO) str[i++] = 'k';
      if (bOOO) str[i++] = 'q';
      str[i] = '\0';
      return [NSString stringWithUTF8String: str];
   }
   else return @"-";
}


- (int)epCandidateSquares:(Square *)squares {
   Position p([startFen UTF8String]);
   return [self epCandidateSquaresForColor: p.side_to_move() toArray: squares];
}


- (int)epCandidateSquaresForColor:(Color)us toArray:(Square *)squares {
   Position p([startFen UTF8String]);
   Color them = opposite_color(us);
   Bitboard rbb = relative_rank_bb(them, RANK_4), b;
   b = p.pawns(them) & rbb;
   b = (((b<<1) & p.pawns(us) & rbb) >> 1) | (((b>>1) & p.pawns(us) & rbb) << 1);
   if (us == WHITE)
      b &= ~((p.occupied_squares() >> 8) | p.occupied_squares() >> 16);
   else
      b &= ~((p.occupied_squares() << 8) | p.occupied_squares() << 16);

   int i = 0;
   while (b) squares[i++] = pop_1st_bit(&b) + pawn_push(us);
   squares[i] = SQ_NONE;
   return i;
}


- (NSString *)fen {
   if (phase == PHASE_EDIT_BOARD)
      return [NSString stringWithFormat: @"%@%c -", [self boardString],
                       ([self blackIsInCheck]? 'b' : 'w')];
   else if (phase == PHASE_EDIT_EP) {
      if (selectedSquare == SQ_NONE)
         return [NSString stringWithString: startFen];
      else {
         NSArray *substrs =
            [startFen componentsSeparatedByCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
         return [NSString stringWithFormat: @"%@ %@ %@ %s",
                    [substrs objectAtIndex: 0],
                    [substrs objectAtIndex: 1],
                    [substrs objectAtIndex: 2],
                          square_to_string(selectedSquare).c_str()];
      }
   }
   else
      return nil;
}


- (void)dealloc {
   for (Piece p = WP; p <= BK; p++)
      ;
}


@end
