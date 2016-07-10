/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "EngineController.h"
#import "GameController.h"
#import "MoveListView.h"
#import "LastMoveView.h"
#import "Options.h"
#import "PieceImageView.h"
#import "PGN.h"
#import "SGActionView.h"

#include "../Chess/misc.h"
#import "Util.h"

using namespace Chess;

@implementation GameController

@synthesize game, rotated;
@dynamic gameMode;

- (id)initWithBoardView:(BoardView *)bv
           moveListView:(MoveListView *)mlv{
   if (self = [super init]) {
      boardView = bv;
      moveListView = mlv;
      [moveListView setGameController: self];
      [moveListView setWebViewDelegate: self];

      game = [[Game alloc] initWithGameController: self];
      pieceViews = [[NSMutableArray alloc] init];
      pendingFrom = SQ_NONE;
      pendingTo = SQ_NONE;
      rotated = NO;
      gameLevel = [[Options sharedOptions] gameLevel];
      gameMode = [[Options sharedOptions] gameMode];
      engineIsPlaying = NO;

      [[NSNotificationCenter defaultCenter]
         addObserver: self
            selector: @selector(pieceSetChanged:)
                name: @"StockfishPieceSetChanged"
              object: nil];

      // Load sounds
      NSURL *soundURL;
      
      for (int i = 0; i < 2; i++) {
         const char pieceNames[7][10] = {"", "Pawn", "Knight", "Bishop", "Rook", "Queen", "King"};
         for (int p = PAWN; p <= KING; p++) {
            soundURL = [[NSBundle mainBundle] URLForResource: [NSString stringWithFormat: @"%s%d", pieceNames[p], i + 1]
                                               withExtension: @"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &pieceSounds[p][i]);
         }
         soundURL = [[NSBundle mainBundle] URLForResource: [NSString stringWithFormat: @"Pawn%d", i + 1]
                                            withExtension: @"wav"];
         AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &pieceSounds[PAWN][i]);
      }
      for (int i = 0; i < 8; i++) {
         soundURL = [[NSBundle mainBundle] URLForResource: [NSString stringWithFormat: @"Capture%d", i + 1]
                                            withExtension:@"wav"];
         AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &captureSounds[i]);
      }

      engineController = nil;
      isPondering = NO;
   }
   return self;
}


- (void)startEngine {
   engineController = [[EngineController alloc] initWithGameController: self];
   [engineController sendCommand: @"uci"];
   [engineController sendCommand: @"isready"];
   [engineController sendCommand: @"ucinewgame"];
   [engineController setPlayStyle: [[Options sharedOptions] playStyle]];
   if ([[Options sharedOptions] permanentBrain])
      [engineController setOption: @"Ponder" value: @"true"];
   else
      [engineController setOption: @"Ponder" value: @"false"];
   [engineController setOption: @"Threads"
                         value: [NSString stringWithFormat: @"%d", [Util CPUCount]]];
#ifdef __LP64__
   // Since we're running on a 64-bit CPU, it's safe to assume that this is a modern
   // device with plenty of RAM, and we can afford a bigger transposition table.
   [engineController setOption: @"Hash" value: @"64"];
#else
   [engineController setOption: @"Hash" value: @"32"];
#endif
   
   [engineController setOption: @"Skill Level" value: [NSString stringWithFormat: @"%d",
                                                       [[Options sharedOptions] strength]]];

   [engineController commitCommands];

   [self showBookMoves];
}


- (Square)rotateSquare:(Square)sq {
   return rotated? Square(SQ_H8 - sq) : sq;
}


/// startNewGame starts a new game, and discards the old one.  Later, we should
/// bring up some dialog to let the user choose time controls, colors etc.
/// before starting the new game.

- (void)startNewGame {
   //NSLog(@"startNewGame");

   [boardView hideLastMove];
   [boardView stopHighlighting];

   for (PieceImageView *piv in pieceViews)
      [piv removeFromSuperview];

   game = [[Game alloc] initWithGameController: self];
   gameLevel = [[Options sharedOptions] gameLevel];
   gameMode = [[Options sharedOptions] gameMode];
  
   pieceViews = [[NSMutableArray alloc] init];
   pendingFrom = SQ_NONE;
   pendingTo = SQ_NONE;

   [moveListView setText: @""];
   [analysisView setText: @""];
   [searchStatsView setText: @""];
   [self showPiecesAnimate: NO];
   engineIsPlaying = NO;
   [engineController abortSearch];
   [engineController sendCommand: @"ucinewgame"];
   [engineController setPlayStyle: [[Options sharedOptions] playStyle]];
   
   [engineController commitCommands];

   [self showBookMoves];

   // Rotate board if the engine plays white:
   if (!rotated && [self computersTurnToMove])
      [self rotateBoardAnimate: NO];
   [self engineGo];
}


- (void)updateMoveList {
   [moveListView setText: [game htmlString]
             scrollToPly: [game currentMoveIndex]];
}


/// UIActionSheet delegate method for handling menu button choices.

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
   if ([[actionSheet title] isEqualToString: @"Promote to"]) {
      // The ugly promotion menu. Promotions are handled by a truly hideous
      // hack, see a comment in the doMoveFrom:to:promotion function for an
      // explanation.
      static const PieceType prom[4] = { QUEEN, ROOK, KNIGHT, BISHOP };
      assert(buttonIndex >= 0 && buttonIndex < 4);
      //[actionSheet release];
      [self doMoveFrom: pendingFrom to: pendingTo promotion: prom[buttonIndex]];
   }
   else if ([[actionSheet title] isEqualToString: @"Promote to:"]) {
      // Another ugly hack: We use a colon at the end of the string to
      // distinguish between promotions in the two move input methods.
      static const PieceType prom[4] = { QUEEN, ROOK, KNIGHT, BISHOP };
      assert(buttonIndex >= 0 && buttonIndex < 4);
      //[actionSheet release];

      // HACK to fix annoying UIActionSheet behavior in iOS 8. Of course we should
      // use UIAlertControllers instead of UIActionSheets in iOS 8, but unfortunately
      // that wouldn't work in iOS 7. Later on, we should probably roll our own
      // modal dialogs that uses UIActionSheets or UIAlertControllers depending on
      // the iOS version.
      if ([game pieceOn: pendingFrom] == EMPTY) {
         return;
      }

      Move m = make_promotion_move(pendingFrom, pendingTo, prom[buttonIndex]);
      BOOL isCapture = [game pieceOn: pendingTo] != EMPTY;
      [self animateMove: m];
      [game doMove: m];

      [self updateMoveList];
      [self showBookMoves];
      [self playMoveSound: piece_of_color_and_type(WHITE, prom[buttonIndex]) capture: isCapture];
      [self gameEndTest];
      [self engineGo];
   }
}


/// moveIsPending tests if there is a pending move waiting for the user to
/// choose the promotion piece. Related to the hideous hack in
/// doMoveFrom:to:promotion.

- (BOOL)moveIsPending {
   return pendingFrom != SQ_NONE;
}

- (Piece)pieceOn:(Square)sq {
   assert(square_is_ok(sq));
   return [game pieceOn: [self rotateSquare: sq]];
}


- (BOOL)pieceCanMoveFrom:(Square)sq {
   assert(square_is_ok(sq));
   return [game pieceCanMoveFrom: [self rotateSquare: sq]];
}


- (int)pieceCanMoveFrom:(Square)fSq to:(Square)tSq {

   fSq = [self rotateSquare: fSq];
   tSq = [self rotateSquare: tSq];

   // If the squares are invalid, the move can't be legal.
   if (!square_is_ok(fSq) || !square_is_ok(tSq))
      return 0;

   // Make sure we don't capture a friendly piece. This is important, because
   // of the way castling moves are encoded.
   if (color_of_piece([game pieceOn: tSq]) == color_of_piece([game pieceOn: fSq]))
      return 0;

   // HACK: Castling. The user probably tries to move the king two squares to
   // the side when castling, but Stockfish internally encodes castling moves
   // as "king captures rook". We handle this by adjusting tSq when the user
   // tries to move the king two squares to the side:
   if (fSq == SQ_E1 && tSq == SQ_G1 && [game pieceOn: fSq] == WK)
      tSq = SQ_H1;
   else if (fSq == SQ_E1 && tSq == SQ_C1 && [game pieceOn: fSq] == WK)
      tSq = SQ_A1;
   else if (fSq == SQ_E8 && tSq == SQ_G8 && [game pieceOn: fSq] == BK)
      tSq = SQ_H8;
   else if (fSq == SQ_E8 && tSq == SQ_C8 && [game pieceOn: fSq] == BK)
      tSq = SQ_A8;

   return [game pieceCanMoveFrom: fSq to: tSq];
}


/// destinationSquaresFrom:saveInArray takes a square and a C array of squares
/// as input, finds all squares the piece on the given square can move to,
/// and stores these possible destination squares in the array. This is used
/// in the GUI in order to highlight the squares a piece can move to.

- (int)destinationSquaresFrom:(Square)sq saveInArray:(Square *)sqs {
   int i, j, n;
   Move mlist[32];

   assert(square_is_ok(sq));
   assert(sqs != NULL);

   sq = [self rotateSquare: sq];

   n = [game movesFrom: sq saveInArray: mlist];
   for (i = 0, j = 0; i < n; i++)
      // Only include non-promotions and queen promotions, in order to avoid
      // having the same destination squares multiple times in the array.
      if (!move_promotion(mlist[i]) || move_promotion(mlist[i]) == QUEEN) {
         // For castling moves, adjust the destination square so that it displays
         // correctly when squares are highlighted in the GUI.
         if (move_is_long_castle(mlist[i]))
            sqs[j] = [self rotateSquare: move_to(mlist[i]) + 2];
         else if (move_is_short_castle(mlist[i]))
            sqs[j] = [self rotateSquare: move_to(mlist[i]) - 1];
         else
            sqs[j] = [self rotateSquare: move_to(mlist[i])];
         j++;
      }
   sqs[j] = SQ_NONE;
   return j;
}


/// doMoveFrom:to:promotion executes a move made by the user, and is called by
/// touchesEnded:withEvent in the PieceImageView class. Legality is checked
/// by that method, so at present we can safely assume that the move is legal.
/// Update the game, and do necessary updates to the board view (remove
/// captured pieces, move rook in case of castling).

- (void)doMoveFrom:(Square)fSq to:(Square)tSq promotion:(PieceType)prom {
   assert(square_is_ok(fSq));
   assert(square_is_ok(tSq));

   fSq = [self rotateSquare: fSq];
   tSq = [self rotateSquare: tSq];
    
   Piece movingPiece = [game pieceOn: fSq];

   // HACK to fix annoying UIActionSheet behavior in iOS 8. Of course we should
   // use UIAlertControllers instead of UIActionSheets in iOS 8, but unfortunately
   // that wouldn't work in iOS 7. Later on, we should probably roll our own
   // modal dialogs that uses UIActionSheets or UIAlertControllers depending on
   // the iOS version.
   if (movingPiece == EMPTY) {
      return;
   }

   BOOL isCapture = [game pieceOn: tSq] != EMPTY;

   if ([game pieceCanMoveFrom: fSq to: tSq] > 1 && prom == NO_PIECE_TYPE) {
      // More than one legal move between the two squares. This means that the
      // user tries to do a promotion move, even though the "prom" parameter
      // doesn't say so. Handling this is really messy, because the iPhone SDK
      // doesn't seem to have anything equivalent to Cocoa's NSAlert() function.
      // What we really want to do is to bring up a modal dialog and wait
      // until the user chooses a piece to promote to. This doesn't seem to be
      // possible: When the user chooses a menu option, the delegate method
      // actionSheet:clickedButtonAtIndex: function is called, and control never
      // returns to the present function.
      //
      // We hack around this problem by remembering fSq and tSq, and calling
      // doMoveFrom:to:promotion again with the remembered values and the chosen
      // promotion piece from the delegate method. This is really ugly.  :-(
      pendingFrom = [self rotateSquare: fSq];
      pendingTo = [self rotateSquare: tSq];
//      UIActionSheet *menu =
//         [[UIActionSheet alloc]
//            initWithTitle: @"Promote to"
//                 delegate: self
//            cancelButtonTitle: nil
//            destructiveButtonTitle: nil
//            otherButtonTitles: @"♕ Queen", @"♖ Rook", @"♘ Knight", @"♗ Bishop", nil];
//      [menu showInView: [boardView superview]];
       
       NSString *pieceSet = [[Options sharedOptions] pieceSet];
       
       if ([game sideToMove] == WHITE) {
           
           strImgQUEEN = [NSString stringWithFormat: @"%@WQueen.png", pieceSet];
           strImgROOK = [NSString stringWithFormat: @"%@WRook.png", pieceSet];
           strImgKNIGHT = [NSString stringWithFormat: @"%@WKnight.png", pieceSet];
           strImgBISHOP = [NSString stringWithFormat: @"%@WBishop.png", pieceSet];
       }else{
           strImgQUEEN = [NSString stringWithFormat: @"%@BQueen.png", pieceSet];
           strImgROOK = [NSString stringWithFormat: @"%@BRook.png", pieceSet];
           strImgKNIGHT = [NSString stringWithFormat: @"%@BKnight.png", pieceSet];
           strImgBISHOP = [NSString stringWithFormat: @"%@BBishop.png", pieceSet];
       }
       
       
           
       [SGActionView showGridMenuWithTitle:@"Promote to"
                                itemTitles:@[@"Queen", @"Rook", @"Knight", @"Bishop"]
                                    images:@[[UIImage imageNamed:strImgQUEEN],
                                             [UIImage imageNamed:strImgROOK],
                                             [UIImage imageNamed:strImgKNIGHT],
                                             [UIImage imageNamed:strImgBISHOP]]
                            selectedHandle:^(NSInteger index) {
                                NSLog(@"Indice %lu",index);
                                
                                if (index>0) {
                                    
                                    index = index-1;

                                    static const PieceType prom[4] = { QUEEN, ROOK, KNIGHT, BISHOP };
                                    assert(index >= 0 && index < 4);
                                    //[actionSheet release];
                                    [self doMoveFrom: pendingFrom to: pendingTo promotion: prom[index]];
                                    
                                }
                                
                            }];
       
      return;
   }

   // HACK: Castling. The user probably tries to move the king two squares to
   // the side when castling, but Stockfish internally encodes castling moves
   // as "king captures rook". We handle this by adjusting tSq when the user
   // tries to move the king two squares to the side:
   static const int woo = 1, wooo = 2, boo = 3, booo = 4;
   int castle = 0;
   if (fSq == SQ_E1 && tSq == SQ_G1 && [game pieceOn: fSq] == WK) {
      tSq = SQ_H1; castle = woo;
   } else if (fSq == SQ_E1 && tSq == SQ_C1 && [game pieceOn: fSq] == WK) {
      tSq = SQ_A1; castle = wooo;
   } else if (fSq == SQ_E8 && tSq == SQ_G8 && [game pieceOn: fSq] == BK) {
      tSq = SQ_H8; castle = boo;
   } else if (fSq == SQ_E8 && tSq == SQ_C8 && [game pieceOn: fSq] == BK) {
      tSq = SQ_A8; castle = booo;
   }

   if (castle) {
      // Move the rook.
      PieceImageView *piv;
      Square rsq;

      if (castle == woo) {
         piv = [self pieceImageViewForSquare:SQ_H1];
         rsq = [self rotateSquare:SQ_F1];
      } else if (castle == wooo) {
         piv = [self pieceImageViewForSquare:SQ_A1];
         rsq = [self rotateSquare:SQ_D1];
      } else if (castle == boo) {
         piv = [self pieceImageViewForSquare:SQ_H8];
         rsq = [self rotateSquare:SQ_F8];
      } else if (castle == booo) {
         piv = [self pieceImageViewForSquare:SQ_A8];
         rsq = [self rotateSquare:SQ_D8];
      } else {
         assert(false);
         rsq = SQ_NONE; // Just to muffle a compiler warning
      }
      [piv moveToSquare: rsq];
      isCapture = NO;
   }
   else if ([game pieceOn: tSq] != EMPTY)
      // Capture. Remove captured piece.
      [self removePieceOn: tSq];
   else if (type_of_piece([game pieceOn: fSq]) == PAWN
            && square_file(tSq) != square_file(fSq)) {
      // Pawn moves to a different file, and destination square is empty. This
      // must be an en passant capture. Remove captured pawn:
      Square epSq = tSq - pawn_push([game sideToMove]);
      assert([game pieceOn: epSq]
             == pawn_of_color(opposite_color([game sideToMove])));
      [self removePieceOn: epSq];
   }

   // In case of promotion, update the piece image view.
   if (prom) {
      [self removePieceOn: fSq];
      [self putPiece: piece_of_color_and_type([game sideToMove], prom)
                  on: tSq];
   }

   // Update the game and move list:
   [game doMoveFrom: fSq to: tSq promotion: prom];
   [self updateMoveList];
   [self showBookMoves];
   pendingFrom = pendingTo = SQ_NONE;

   // Play a sound when the move has been made.
   [self playMoveSound: movingPiece capture: isCapture];

   // Game over?
   [self gameEndTest];

   // Clear the search stats view
   [searchStatsView setText: @""];

   // HACK to handle promotions
   if (prom)
      [self engineGo];
}


- (void)promotionMenu {
//   [[[UIActionSheet alloc]
//       initWithTitle: @"Promote to:"
//            delegate: self
//       cancelButtonTitle: nil
//       destructiveButtonTitle: nil
//       otherButtonTitles: @"♕ Queen", @"♖ Rook", @"♘ Knight", @"♗ Bishop", nil]
//      showInView: [boardView superview]];
    
    NSString *pieceSet = [[Options sharedOptions] pieceSet];
    
    if ([game sideToMove] == WHITE) {
        
        strImgQUEEN = [NSString stringWithFormat: @"%@WQueen.png", pieceSet];
        strImgROOK = [NSString stringWithFormat: @"%@WRook.png", pieceSet];
        strImgKNIGHT = [NSString stringWithFormat: @"%@WKnight.png", pieceSet];
        strImgBISHOP = [NSString stringWithFormat: @"%@WBishop.png", pieceSet];
    }else{
        strImgQUEEN = [NSString stringWithFormat: @"%@BQueen.png", pieceSet];
        strImgROOK = [NSString stringWithFormat: @"%@BRook.png", pieceSet];
        strImgKNIGHT = [NSString stringWithFormat: @"%@BKnight.png", pieceSet];
        strImgBISHOP = [NSString stringWithFormat: @"%@BBishop.png", pieceSet];
    }
    
    [SGActionView showGridMenuWithTitle:@"Promote to"
                             itemTitles:@[@"Queen", @"Rook", @"Knight", @"Bishop"]
                                 images:@[[UIImage imageNamed:strImgQUEEN],
                                          [UIImage imageNamed:strImgROOK],
                                          [UIImage imageNamed:strImgKNIGHT],
                                          [UIImage imageNamed:strImgBISHOP]]
                         selectedHandle:^(NSInteger index) {
                             NSLog(@"Indice %lu",index);
                             if (index>0) {
                                 index = index-1;
                                 
                                 // Another ugly hack: We use a colon at the end of the string to
                                 // distinguish between promotions in the two move input methods.
                                 static const PieceType prom[4] = { QUEEN, ROOK, KNIGHT, BISHOP };
                                 assert(index >= 0 && index < 4);
                                 //[actionSheet release];
                                 
                                 // HACK to fix annoying UIActionSheet behavior in iOS 8. Of course we should
                                 // use UIAlertControllers instead of UIActionSheets in iOS 8, but unfortunately
                                 // that wouldn't work in iOS 7. Later on, we should probably roll our own
                                 // modal dialogs that uses UIActionSheets or UIAlertControllers depending on
                                 // the iOS version.
                                 if ([game pieceOn: pendingFrom] == EMPTY) {
                                     return;
                                 }
                                 
                                 Move m = make_promotion_move(pendingFrom, pendingTo, prom[index]);
                                 BOOL isCapture = [game pieceOn: pendingTo] != EMPTY;
                                 [self animateMove: m];
                                 [game doMove: m];
                                 
                                 [self updateMoveList];
                                 [self showBookMoves];
                                 [self playMoveSound: piece_of_color_and_type(WHITE, prom[index]) capture: isCapture];
                                 [self gameEndTest];
                                 [self engineGo];
                             }

                             
                         }];
}


- (void)animateMoveFrom:(Square)fSq to:(Square)tSq {
   assert(square_is_ok(fSq));
   assert(square_is_ok(tSq));

   fSq = [self rotateSquare: fSq];
   tSq = [self rotateSquare: tSq];
    
//   [boardView showLastMoveWithFrom: fSq to: tSq]; //deixar marcado o último movimento do usuário
    
   Piece movingPiece = [game pieceOn: fSq];
   BOOL isCapture = [game pieceOn: tSq] != EMPTY;

   if ([game pieceCanMoveFrom: fSq to: tSq] > 1) {
      pendingFrom = fSq;
      pendingTo = tSq;
      [self promotionMenu];
      return;
   }

   // HACK: Castling. The user probably tries to move the king two squares to
   // the side when castling, but Stockfish internally encodes castling moves
   // as "king captures rook". We handle this by adjusting tSq when the user
   // tries to move the king two squares to the side:
   static const int woo = 1, wooo = 2, boo = 3, booo = 4;
   int castle = 0;
   BOOL ep = NO;
   if (fSq == SQ_E1 && tSq == SQ_G1 && [game pieceOn: fSq] == WK) {
      tSq = SQ_H1; castle = woo;
   } else if (fSq == SQ_E1 && tSq == SQ_C1 && [game pieceOn: fSq] == WK) {
      tSq = SQ_A1; castle = wooo;
   } else if (fSq == SQ_E8 && tSq == SQ_G8 && [game pieceOn: fSq] == BK) {
      tSq = SQ_H8; castle = boo;
   } else if (fSq == SQ_E8 && tSq == SQ_C8 && [game pieceOn: fSq] == BK) {
      tSq = SQ_A8; castle = booo;
   }
   else if (type_of_piece([game pieceOn: fSq]) == PAWN &&
            [game pieceOn: tSq] == EMPTY &&
            square_file(fSq) != square_file(tSq))
      ep = YES;

   Move m;
   if (castle) {
      isCapture = NO;
      m = make_castle_move(fSq, tSq);
   }
   else if (ep)
      m = make_ep_move(fSq, tSq);
   else
      m = make_move(fSq, tSq);

   [self animateMove: m];
   [game doMove: m];

   [self updateMoveList];
   [self showBookMoves];
   [self playMoveSound: movingPiece capture: isCapture];
   [self gameEndTest];
   [self engineGo];
}


/// removePieceOn: removes a piece from the board view.  The piece is
/// assumed to still be present on the board in the current position
/// in the game: The method is called directly before a captured piece
/// is removed from the game board.

- (void)removePieceOn:(Square)sq {
   sq = [self rotateSquare: sq];
   assert(square_is_ok(sq));
   for (int i = 0; i < [pieceViews count]; i++)
      if ([pieceViews[i] square] == sq) {
         [pieceViews[i] removeFromSuperview];
         [pieceViews removeObjectAtIndex: i];
         break;
      }
}


/// putPiece:on: inserts a new PieceImage subview to the board view. This method
/// is called when the user takes back a capturing move.

- (void)putPiece:(Piece)p on:(Square)sq {
   assert(piece_is_ok(p));
   assert(square_is_ok(sq));

   sq = [self rotateSquare: sq];

   float sqSize = [boardView sqSize];
   CGRect rect = CGRectMake(0.0f, 0.0f, sqSize, sqSize);
   rect.origin = CGPointMake((int(sq)%8) * sqSize, (7-int(sq)/8) * sqSize);
   PieceImageView *piv = [[PieceImageView alloc] initWithFrame: rect
                                                gameController: self
                                                     boardView: boardView];
   [piv setImage: pieceImages[p]];
   [piv setUserInteractionEnabled: YES];
   [piv setAlpha: 0.0];
   [boardView addSubview: piv];
   [pieceViews addObject: piv];

   CGContextRef context = UIGraphicsGetCurrentContext();
   [UIView beginAnimations: nil context: context];
   [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDuration: 0.25];
   [piv setAlpha: 1.0];
   [UIView commitAnimations];

}


/// takeBackMove takes back the last move played, unless we are at the beginning
/// of the game, in which case nothing happens. Both the game and the board view
/// are updated. We should maybe highlight the current move in the move list,
/// too, but this seems tricky.

- (void)takeBackMove {
   if (![game atBeginning]) {
      ChessMove *cm = [game previousMove];
      Square from = move_from([cm move]), to = move_to([cm move]);
      UndoInfo ui = [cm undoInfo];

      // If the engine is pondering, stop it before unmaking the move.
      if (isPondering) {
         NSLog(@"pondermiss because of take back");
         [engineController pondermiss];
         isPondering = NO;
      }

      // HACK: Castling. Stockfish internally encodes castling moves as "king
      // captures rook", which means that the "to" square does not contain the
      // king's current square on the board. Adjust the "to" square, and check
      // what sort of castling move it is, to help us move the rook back home
      // later.
      static const int woo = 1, wooo = 2, boo = 3, booo = 4;
      int castle = 0;
      if (move_is_short_castle([cm move])) {
         castle = ([game sideToMove] == BLACK)? woo : boo;
         to = ([game sideToMove] == BLACK)? SQ_G1 : SQ_G8;
      }
      else if (move_is_long_castle([cm move])) {
         castle = ([game sideToMove] == BLACK)? wooo : booo;
         to = ([game sideToMove] == BLACK)? SQ_C1 : SQ_C8;
      }

      // In case of promotion, unpromote the piece before moving it back:
      if (move_promotion([cm move]))
         [[self pieceImageViewForSquare: to]
            setImage: pieceImages[pawn_of_color(opposite_color([game sideToMove]))]];

      // Put the moving piece back at its source square:
      [[self pieceImageViewForSquare: to] moveToSquare:
                                    [self rotateSquare: from]];

      // For castling moves, move the rook back:
      if (castle == woo)
         [[self pieceImageViewForSquare: SQ_F1]
            moveToSquare: [self rotateSquare: SQ_H1]];
      else if (castle == wooo)
         [[self pieceImageViewForSquare: SQ_D1]
            moveToSquare: [self rotateSquare: SQ_A1]];
      else if (castle == boo)
         [[self pieceImageViewForSquare: SQ_F8]
            moveToSquare: [self rotateSquare: SQ_H8]];
      else if (castle == booo)
         [[self pieceImageViewForSquare: SQ_D8]
            moveToSquare: [self rotateSquare: SQ_A8]];

      // In the case of a capture, put the captured piece back on the board.
      if (move_is_ep([cm move]))
         [self putPiece: pawn_of_color([game sideToMove])
                     on: to + pawn_push([game sideToMove])];
      else if (ui.capture)
         [self putPiece: piece_of_color_and_type([game sideToMove], ui.capture)
                     on: to];

      // Don't show the last move played any more:
      [boardView hideLastMove];
      [boardView stopHighlighting];

      // Stop engine:
      if ([self computersTurnToMove]) {
         engineIsPlaying = NO;
         [engineController abortSearch];
         [engineController commitCommands];
      }

      // Update the game:
      [game takeBack];

      // If in analyse mode, send new position to engine, and tell it to start
      // thinking:
      if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
         [engineController abortSearch];
         [engineController sendCommand: [game uciGameString]];
         [engineController sendCommand: @"go infinite"];
         [engineController commitCommands];
      }
   }
   [self updateMoveList];
   [self showBookMoves];
}


- (void)takeBackAllMoves {
   if (![game atBeginning]) {

      [boardView hideLastMove];
      [boardView stopHighlighting];

      // Release piece images
      for (PieceImageView *piv in pieceViews)
         [piv removeFromSuperview];

      // Update game
      [game toBeginning];

      // Update board
      pieceViews = [[NSMutableArray alloc] init];
      [self showPiecesAnimate: NO];

      // Stop engine:
      if ([self computersTurnToMove]) {
         engineIsPlaying = NO;
         [engineController abortSearch];
         [engineController commitCommands];
      }

      // If in analyse mode, send new position to engine, and tell it to start
      // thinking:
      if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
         [engineController abortSearch];
         [engineController sendCommand: [game uciGameString]];
         [engineController sendCommand: @"go infinite"];
         [engineController commitCommands];
      }

      [self updateMoveList];
      [self showBookMoves];
   }
}


- (void)animateMove:(Move)m {
   Square from = move_from(m), to = move_to(m);
    
    [boardView showLastMoveWithFrom: [self rotateSquare: from]
                                 to: [self rotateSquare: to]];

   // HACK: Castling. Stockfish internally encodes castling moves as "king
   // captures rook", which means that the "to" square does not contain the
   // king's current square on the board. Adjust the "to" square, and check
   // what sort of castling move it is, to help us move the rook later.
   static const int woo = 1, wooo = 2, boo = 3, booo = 4;
   int castle = 0;
   if (move_is_short_castle(m)) {
      castle = ([game sideToMove] == WHITE)? woo : boo;
      to = ([game sideToMove] == WHITE)? SQ_G1 : SQ_G8;
   }
   else if (move_is_long_castle(m)) {
      castle = ([game sideToMove] == WHITE)? wooo : booo;
      to = ([game sideToMove] == WHITE)? SQ_C1 : SQ_C8;
   }

   // In the case of a capture, remove the captured piece.
   if ([game pieceOn: to] != EMPTY)
      [self removePieceOn: to];
   else if (move_is_ep(m))
      [self removePieceOn: to - pawn_push([game sideToMove])];

   // Move the piece
   [[self pieceImageViewForSquare: from] moveToSquare:
                                   [self rotateSquare: to]];

   // If move is promotion, update the piece image:
   if (move_promotion(m))
      [[self pieceImageViewForSquare: to]
         setImage:
            pieceImages[piece_of_color_and_type([game sideToMove],
                                                move_promotion(m))]];

   // If move is a castle, move the rook
   if (castle == woo)
      [[self pieceImageViewForSquare: SQ_H1]
         moveToSquare: [self rotateSquare: SQ_F1]];
   else if (castle == wooo)
      [[self pieceImageViewForSquare: SQ_A1]
         moveToSquare: [self rotateSquare: SQ_D1]];
   else if (castle == boo)
      [[self pieceImageViewForSquare: SQ_H8]
         moveToSquare: [self rotateSquare: SQ_F8]];
   else if (castle == booo)
      [[self pieceImageViewForSquare: SQ_A8]
         moveToSquare: [self rotateSquare: SQ_D8]];
}


/// replayMove steps forward one move in the game, unless we are at the end of
/// the game, in which case nothing happens. Both the game and the board view
/// are updated. We should maybe highlight the current move in the move list,
/// too, but this seems tricky.

- (void)replayMove {
   NSLog(@"replayMove, [game atEnd] is %d", [game atEnd]);
   if (![game atEnd]) {
      ChessMove *cm = [game nextMove];

      [self animateMove: [cm move]];

      // Update the game:
      [game stepForward];

      // Don't show the last move played any more:
      [boardView hideLastMove];
      [boardView stopHighlighting];

      // If in analyse mode, send new position to engine, and tell it to start
      // thinking:
      if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
         [engineController abortSearch];
         [engineController sendCommand: [game uciGameString]];
         [engineController sendCommand: @"go infinite"];
         [engineController commitCommands];
      }
      [self updateMoveList];
      [self showBookMoves];

   }
}


- (void)replayAllMoves {
   if (![game atEnd]) {

      [boardView hideLastMove];
      [boardView stopHighlighting];

      // Release piece images
      for (PieceImageView *piv in pieceViews)
         [piv removeFromSuperview];

      // Update game
      [game toEnd];

      // Update board
      pieceViews = [[NSMutableArray alloc] init];
      [self showPiecesAnimate: NO];

      // Stop engine:
      if ([self computersTurnToMove]) {
         engineIsPlaying = NO;
         [engineController abortSearch];
         [engineController commitCommands];
      }

      // If in analyse mode, send new position to engine, and tell it to start
      // thinking:
      if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
         [engineController abortSearch];
         [engineController sendCommand: [game uciGameString]];
         [engineController sendCommand: @"go infinite"];
         [engineController commitCommands];
      }
       
      [self updateMoveList];
      [self showBookMoves];
   }
}


- (void)simpleMoveAnimationFinished:(NSString *)animationId
                           finished:(BOOL)finished
                            context:(void *)context {
   NSArray *array = [animationId componentsSeparatedByString: @" "];
   NSInteger fromPly, toPly, currentPly;
   [[NSScanner scannerWithString: array[0]] scanInteger: &fromPly];
   [[NSScanner scannerWithString: array[1]] scanInteger: &toPly];
   [[NSScanner scannerWithString: array[2]] scanInteger: &currentPly];
   if (currentPly > toPly)
      [self takeBackMovesFrom: (int)fromPly to: (int)toPly current: (int)currentPly];
   else
      [self replayMovesFrom: (int)fromPly to: (int)toPly current: (int)currentPly];
}


- (void)takeBackMovesFrom:(int)fromPly to:(int)toPly current:(int)currentPly {
   if (![game atBeginning]) {
      ChessMove *cm = [game previousMove];
      Square from = move_from([cm move]), to = move_to([cm move]);
      UndoInfo ui = [cm undoInfo];
      
      // HACK: Castling. Stockfish internally encodes castling moves as "king
      // captures rook", which means that the "to" square does not contain the
      // king's current square on the board. Adjust the "to" square, and check
      // what sort of castling move it is, to help us move the rook back home
      // later.
      static const int woo = 1, wooo = 2, boo = 3, booo = 4;
      int castle = 0;
      if (move_is_short_castle([cm move])) {
         castle = ([game sideToMove] == BLACK)? woo : boo;
         to = ([game sideToMove] == BLACK)? SQ_G1 : SQ_G8;
      } else if (move_is_long_castle([cm move])) {
         castle = ([game sideToMove] == BLACK)? wooo : booo;
         to = ([game sideToMove] == BLACK)? SQ_C1 : SQ_C8;
      }

      // In case of promotion, unpromote the piece before moving it back:
      if (move_promotion([cm move]))
         [[self pieceImageViewForSquare: to]
            setImage: pieceImages[pawn_of_color(opposite_color([game sideToMove]))]];

      float duration =
         (abs(toPly - currentPly) > 30)? 0.002f :
         (abs(toPly - currentPly) > 20)? 0.005f :
         (abs(toPly - currentPly) > 10)? 0.01f : 0.02f;

      // For castling moves, move the rook back:
      if (currentPly - toPly == 1) {
         if (castle == woo)
            [[self pieceImageViewForSquare: SQ_F1]
               moveToSquare: [self rotateSquare: SQ_H1]];
         else if (castle == wooo)
            [[self pieceImageViewForSquare: SQ_D1]
               moveToSquare: [self rotateSquare: SQ_A1]];
         else if (castle == boo)
            [[self pieceImageViewForSquare: SQ_F8]
               moveToSquare: [self rotateSquare: SQ_H8]];
         else if (castle == booo)
            [[self pieceImageViewForSquare: SQ_D8]
               moveToSquare: [self rotateSquare: SQ_A8]];
      } else {
         Square rfrom, rto;
         if (castle == woo) rfrom = SQ_F1, rto = SQ_H1;
         else if (castle == wooo) rfrom = SQ_D1, rto = SQ_A1;
         else if (castle == boo) rfrom = SQ_F8, rto = SQ_H8;
         else if (castle == booo) rfrom = SQ_D8, rto = SQ_A8;
         if (castle == woo || castle == wooo || castle == boo || castle == booo)
            [[self pieceImageViewForSquare: rfrom]
               simpleMoveToSquare: [self rotateSquare: rto]
                         duration: duration/2
                          fromPly: 0
                            toPly: -1
                       currentPly: 0];
      }

      // Put the moving piece back at its source square:
      if (currentPly - toPly == 1) {
         [[self pieceImageViewForSquare: to] moveToSquare:
                                       [self rotateSquare: from]];
      } else {
         [[self pieceImageViewForSquare: to]
            simpleMoveToSquare: [self rotateSquare: from]
                      duration: duration
                       fromPly: fromPly
                         toPly: toPly
                    currentPly: (currentPly - 1)];
      }

      // In case of a capture, put the captured piece back on the board.
      if (move_is_ep([cm move]))
         [self putPiece: pawn_of_color([game sideToMove])
                     on: to + pawn_push([game sideToMove])];
      else if (ui.capture)
         [self putPiece: piece_of_color_and_type([game sideToMove], ui.capture)
                     on: to];

      // Update the game:
      [game takeBack];

      // If this is the last move to be taken back, update the move list
      // and book moves, and start thinking if necessary:
      if (currentPly - toPly == 1) {
         [self updateMoveList];
         [self showBookMoves];

         if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
            [engineController sendCommand: [game uciGameString]];
            [engineController sendCommand: @"go infinite"];
            [engineController commitCommands];
         }
      }
   }
}


- (void)replayMovesFrom:(int)fromPly to:(int)toPly current:(int)currentPly {
   if (![game atEnd]) {
      ChessMove *cm = [game nextMove];
      Square from = move_from([cm move]), to = move_to([cm move]);

      // HACK: Castling. Stockfish internally encodes castling moves as "king
      // captures rook", which means that the "to" square does not contain the
      // king's current square on the board. Adjust the "to" square, and check
      // what sort of castling move it is, to help us move the rook later.
      static const int woo = 1, wooo = 2, boo = 3, booo = 4;
      int castle = 0;
      if (move_is_short_castle([cm move])) {
         castle = ([game sideToMove] == WHITE)? woo : boo;
         to = ([game sideToMove] == WHITE)? SQ_G1 : SQ_G8;
      }
      else if (move_is_long_castle([cm move])) {
         castle = ([game sideToMove] == WHITE)? wooo : booo;
         to = ([game sideToMove] == WHITE)? SQ_C1 : SQ_C8;
      }
      
      // In the case of a capture, remove the captured piece.
      if ([game pieceOn: to] != EMPTY)
         [self removePieceOn: to];
      else if (move_is_ep([cm move]))
         [self removePieceOn: to - pawn_push([game sideToMove])];

      float duration =
         (abs(toPly - currentPly) > 30)? 0.002f :
         (abs(toPly - currentPly) > 20)? 0.005f :
         (abs(toPly - currentPly) > 10)? 0.01f : 0.02f;

      // Move the piece:
      if (toPly - currentPly == 1)
         [[self pieceImageViewForSquare: from]
               moveToSquare: [self rotateSquare: to]];
      else
         [[self pieceImageViewForSquare: from]
            simpleMoveToSquare: [self rotateSquare: to]
                      duration: duration
                       fromPly: fromPly
                         toPly: toPly
                    currentPly: (currentPly + 1)];

      // If move is promotion, update the piece image:
      if (move_promotion([cm move]))
         [[self pieceImageViewForSquare: to]
            setImage:
               pieceImages[piece_of_color_and_type([game sideToMove],
                                                   move_promotion([cm move]))]];

      // If move is a castle, move the rook:
      if (toPly - currentPly == 1) {
         if (castle == woo)
            [[self pieceImageViewForSquare: SQ_H1]
               moveToSquare: [self rotateSquare: SQ_F1]];
         else if (castle == wooo)
            [[self pieceImageViewForSquare: SQ_A1]
               moveToSquare: [self rotateSquare: SQ_D1]];
         else if (castle == boo)
            [[self pieceImageViewForSquare: SQ_H8]
               moveToSquare: [self rotateSquare: SQ_F8]];
         else if (castle == booo)
            [[self pieceImageViewForSquare: SQ_A8]
               moveToSquare: [self rotateSquare: SQ_D8]];
      } else {
         Square rfrom, rto;
         if (castle == woo) rfrom = SQ_H1, rto = SQ_F1;
         else if (castle == wooo) rfrom = SQ_A1, rto = SQ_D1;
         else if (castle == boo) rfrom = SQ_H8, rto = SQ_F8;
         else if (castle == booo) rfrom = SQ_A8, rto = SQ_D8;
         if (castle == woo || castle == wooo || castle == boo || castle == booo)
            [[self pieceImageViewForSquare: rfrom]
               simpleMoveToSquare: [self rotateSquare: rto]
                         duration: duration/2
                          fromPly: 0
                            toPly: -1
                       currentPly: 0];
      }
      
      // Update the game:
      [game stepForward];

      // If this is the last move to be replayed, update the move list
      // and book moves, and start thinking if necessary:
      if (toPly - currentPly == 1) {
         [self updateMoveList];
         [self showBookMoves];

         if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
            [engineController sendCommand: [game uciGameString]];
            [engineController sendCommand: @"go infinite"];
            [engineController commitCommands];
         }
      }
   }
}


- (void)jumpToPly:(int)ply animate:(BOOL)animate {
   [boardView hideLastMove];
   [boardView stopHighlighting];

   if (ply == [game currentMoveIndex])
      return;

   // If the engine is pondering, stop it before unmaking the move.
   if (isPondering) {
      NSLog(@"pondermiss because of take back");
      [engineController pondermiss];
      isPondering = NO;
   }
   
   // Stop engine:
   if ([self computersTurnToMove]) {
      engineIsPlaying = NO;
      [engineController abortSearch];
      [engineController commitCommands];
   }

   if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
      [engineController abortSearch];
      [engineController commitCommands];
   }
   
   if (animate) {
      if (ply < [game currentMoveIndex]) {
         [self takeBackMovesFrom: [game currentMoveIndex]
                              to: ply
                         current: [game currentMoveIndex]];
      } else {
         [self replayMovesFrom: [game currentMoveIndex]
                            to: ply
                       current: [game currentMoveIndex]];
      }
      return;
   }

   // Release piece images
   for (PieceImageView *piv in pieceViews)
      [piv removeFromSuperview];

   // Go to the right location in the game
   [game toPly: ply];
   
   // Update board
   pieceViews = [[NSMutableArray alloc] init];
   [self showPiecesAnimate: NO];
   
   // Stop engine:
   if ([self computersTurnToMove]) {
      engineIsPlaying = NO;
      [engineController abortSearch];
      [engineController commitCommands];
   }
   
   // If in analyse mode, send new position to engine, and tell it to start
   // thinking:
   if (gameMode == GAME_MODE_ANALYSE && ![game positionIsTerminal]) {
      [engineController abortSearch];
      [engineController sendCommand: [game uciGameString]];
      [engineController sendCommand: @"go infinite"];
      [engineController commitCommands];
   }
   
   [self updateMoveList];
   [self showBookMoves];
}


/// showPiecesAnimate: creates the piece image views and attaches them as
/// subviews to the board view.  There is a boolean parameter which tells
/// the method whether the pieces should appear gradually or instantly.

- (void)showPiecesAnimate:(BOOL)animate {
   float sqSize = [boardView sqSize];
   CGRect rect = CGRectMake(0.0f, 0.0f, sqSize, sqSize);
   for (Square sq = SQ_A1; sq <= SQ_H8; sq++) {
      Square s = [self rotateSquare: sq];
      Piece p = [self pieceOn: s];
      if (p != EMPTY) {
         assert(piece_is_ok(p));
         rect.origin = CGPointMake((int(s)%8) * sqSize, (7-int(s)/8) * sqSize);
         PieceImageView *piv = [[PieceImageView alloc] initWithFrame: rect
                                                      gameController: self
                                                           boardView: boardView];
         [piv setImage: pieceImages[p]];
         [piv setUserInteractionEnabled: YES];
         [piv setAlpha: 0.0];
         [boardView addSubview: piv];
         [pieceViews addObject: piv];
      }
   }
   if (animate) {
      CGContextRef context = UIGraphicsGetCurrentContext();
      [UIView beginAnimations: nil context: context];
      [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
      [UIView setAnimationDuration: 1.2];
      for (PieceImageView *piv in pieceViews)
         [piv setAlpha: 1.0];
      [UIView commitAnimations];
   } else
      for (PieceImageView *piv in pieceViews)
         [piv setAlpha: 1.0];
}


- (PieceImageView *)pieceImageViewForSquare:(Square)sq {
   sq = [self rotateSquare: sq];
   for (PieceImageView *piv in pieceViews)
      if ([piv square] == sq)
         return piv;
   return nil;
}


- (void)rotateBoardAnimate:(BOOL)animate {
   rotated = !rotated;
   for (PieceImageView *piv in pieceViews)
      [piv moveToSquare: Square(SQ_H8 - [piv square]) animate: animate];
   [boardView hideLastMove];
   [boardView stopHighlighting];
   [boardView setRotated: rotated];

}

- (void)rotateBoard {
#pragma-mark ALTEREI O VALOR DE ANIMAÇÃO AO VIRAR O TABULEIRO DE YES PARA NO
   [self rotateBoardAnimate: NO];
}


- (void)rotateBoard:(BOOL)rotate animate:(BOOL)animate {
   if (rotate != rotated)
      [self rotateBoardAnimate: animate];
}


- (void)rotateBoard:(BOOL)rotate {
   [self rotateBoard: rotate animate: YES];
}


/// showHint displays a suggestion for a good move to the user. At the
/// moment, it just displays a random legal move.

- (void)showHint {
   if (gameMode == GAME_MODE_ANALYSE)
      [[[UIAlertView alloc] initWithTitle: @"Hints are not available in analyse mode!"
                                   message: nil
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
         show];
   else if (gameMode == GAME_MODE_TWO_PLAYER)
      [[[UIAlertView alloc] initWithTitle: @"Hints are not available in two player mode!"
                                   message: nil
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
         show];
   else {
      Move mlist[256], m;
      //int n;
      [game generateLegalMoves: mlist];
      m = [game getBookMove];

      if (m == MOVE_NONE)
         m = [game getHintForCurrentPosition];

      if (m != MOVE_NONE) {
         Square to = move_to(m);
         if (move_is_long_castle(m)) to += 2;
         else if (move_is_short_castle(m)) to -= 1;
         [[self pieceImageViewForSquare: move_from(m)]
            moveToSquareAndBack: [self rotateSquare: to]];
      }
      else
         [[[UIAlertView alloc] initWithTitle: @"No hint available!"
                                      message: nil
                                     delegate: self
                            cancelButtonTitle: nil
                            otherButtonTitles: @"OK", nil]
            show];
   }
}

- (void)playMoveSound:(Piece)p capture:(BOOL)capture {
   if ([[Options sharedOptions] moveSound]) {
      if (capture)
         AudioServicesPlaySystemSound(captureSounds[random() & 7]);
      else if (piece_is_ok(p))
         AudioServicesPlaySystemSound(pieceSounds[int(p) & 7][random() % 2]);
   }
}


- (void)displayPV:(NSString *)pv
            depth:(int)depth
            score:(int)score
        scoreType:(int)scoreType
             mate:(BOOL)mate {
   if (![Options sharedOptions].showAnalysis) {
      [analysisView setText: @""];
   } else {
      NSString *prettyPV = [game prettyPV:pv
                                    depth:depth
                                    score:score
                                scoreType:scoreType
                                     mate:mate];
      if (prettyPV != nil) {
         if ([Options sharedOptions].figurineNotation) {
            prettyPV = [Util translateToFigurine: prettyPV];
         }
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [analysisView setText: [NSString stringWithFormat: @"  %@", prettyPV]];
         } else {
            [analysisView setText: prettyPV];
         }
      }
   }
}


- (void)displayCurrentMove:(NSString *)currentMove
         currentMoveNumber:(int)currentMoveNumber
             numberOfMoves:(int)totalMoveCount
                     depth:(int)depth
                      time:(long)time
                     nodes:(int64_t)nodes {

   if (![[Options sharedOptions] showAnalysis]) {
      [searchStatsView setText: @""];
      return;
   }

   Move move = [game moveFromString:currentMove];
   if (move == MOVE_NONE) {
      [searchStatsView setText: @""];
      return;
   }

   NSMutableString *buf = [NSMutableString stringWithString: @" "];

   long hours = time / (1000 * 60 * 60);
   long minutes = (time - hours * (1000 * 60 * 60)) / (1000 * 60);
   long seconds = (time - hours * (1000 * 60 * 60) - minutes * (1000 * 60)) / 1000;
   if (hours > 0) {
      [buf appendFormat: @"%ld:", hours];
   }
   [buf appendFormat: @"%02ld:%02ld  ", minutes, seconds];
   [buf appendFormat: @"%d  ", depth];
   if ([[Options sharedOptions] figurineNotation]) {
      [buf appendFormat: @"%@ ", [Util translateToFigurine: [game moveToSAN:move]]];
   } else {
      [buf appendFormat: @"%@ ", [game moveToSAN:move]];
   }
   [buf appendFormat: @"(%d/%d)  ", currentMoveNumber, totalMoveCount];
   if (nodes < 1000000000) {
      [buf appendFormat: @"%lldkN  ", nodes / 1000];
   } else {
      [buf appendFormat: @"%.1fMN  ", nodes / 1000000.0];
   }
   if (time > 0) {
      [buf appendFormat: @"%.1fkN/s", (nodes * 1.0) / time];
   }
   [searchStatsView setText: buf];
}


- (void)setGameLevel:(GameLevel)newGameLevel {
   NSLog(@"new game level: %d", newGameLevel);
   gameLevel = newGameLevel;
   if ([[Options sharedOptions] isFixedTimeLevel]) {
      NSLog(@"fixed time: %d", [[Options sharedOptions] timeIncrement]);
   }
   else {
      NSLog(@"base time: %d increment: %d",
            [[Options sharedOptions] baseTime],
            [[Options sharedOptions] timeIncrement]);
   }
}

- (GameMode)gameMode {
   return gameMode;
}

- (void)setGameMode:(GameMode)newGameMode {
   NSLog(@"new game mode: %d", newGameMode);
   if (gameMode == GAME_MODE_ANALYSE && newGameMode != GAME_MODE_ANALYSE) {
      [engineController pondermiss]; // HACK
      [engineController setOption: @"UCI_AnalyseMode" value: @"false"];
      [engineController commitCommands];
   } else if (isPondering) {
      NSLog(@"pondermiss because game mode changed while pondering");
      [engineController pondermiss];
      isPondering = NO;
   }
   [game setWhitePlayer:ENGINE_NAME];
   [game setBlackPlayer:ENGINE_NAME];
   gameMode = newGameMode;

   // If in analyse mode, automatically switch on "Show analysis"
   if (gameMode == GAME_MODE_ANALYSE) {
      [[Options sharedOptions] setShowAnalysis: YES];
      [[boardView superview] bringSubviewToFront: searchStatsView];
      [searchStatsView setNeedsDisplay];
   } else {
      [[boardView superview] sendSubviewToBack:searchStatsView];
   }

   // Rotate board if necessary:
   if ((gameMode == GAME_MODE_COMPUTER_WHITE && !rotated) ||
       (gameMode == GAME_MODE_COMPUTER_BLACK && rotated))
      [self rotateBoard];

   // Start thinking if necessary:
   [self engineGo];
}


- (void)doEngineMove:(Move)m {
   Square to = move_to(m);
   if (move_is_long_castle(m)) to += 2;
   else if (move_is_short_castle(m)) to -= 1;
   [boardView showLastMoveWithFrom: [self rotateSquare: move_from(m)]
                                to: [self rotateSquare: to]];

   [self animateMove: m];
   [game doMove: m];

   [self updateMoveList];
   [self showBookMoves];
}


/// engineGo is called directly after the user has made a move.  It checks
/// the game mode, and sends a UCI "go" command to the engine if necessary.

- (void)engineGo {
   if (!engineController)
      [self startEngine];

   if ([game positionIsTerminal]) {
      if ([self engineIsThinking])
         [engineController abortSearch];
   } else {
      if (gameMode == GAME_MODE_ANALYSE) {
         engineIsPlaying = NO;
         [engineController abortSearch];
         [engineController sendCommand: [game uciGameString]];
         [engineController setOption: @"UCI_AnalyseMode" value: @"true"];
         [engineController sendCommand: @"go infinite"];
         [engineController commitCommands];
         return;
      }
      if (isPondering) {
         if ([game currentMove] == ponderMove) {
            [engineController ponderhit];
            isPondering = NO;
            return;
         } else {
            NSLog(@"REAL pondermiss");
            [engineController pondermiss];
            while ([engineController engineIsThinking]);
         }
         isPondering = NO;
      }
      if ((gameMode==GAME_MODE_COMPUTER_BLACK && [game sideToMove]==BLACK) ||
          (gameMode==GAME_MODE_COMPUTER_WHITE && [game sideToMove]==WHITE)) {
         // Computer's turn to move.  First look for a book move.  If no book move
         // is found, start a search.
          
         [[NSNotificationCenter defaultCenter] postNotificationName:@"startActivityIndicator" object:nil];
          
         Move m;
         if ([[Options sharedOptions] maxStrength] ||
             [game currentMoveIndex] < 10 + [[Options sharedOptions] strength] * 2)
            m = [game getBookMove];
         else
            m = MOVE_NONE;
          if (m != MOVE_NONE){
            [self doEngineMove: m];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopActivityIndicator" object:nil];
          }else {
            // Update play style, if necessary
            if ([[Options sharedOptions] playStyleWasChanged]) {
               NSLog(@"play style was changed to: %@",
                     [[Options sharedOptions] playStyle]);
               [engineController setPlayStyle: [[Options sharedOptions] playStyle]];
               [engineController commitCommands];
            }

            // Update strength, if necessary
            if ([[Options sharedOptions] strengthWasChanged]) {
               [engineController sendCommand: @"setoption name Clear Hash"];
               [engineController setOption: @"Skill Level" value: [NSString stringWithFormat: @"%d",
                                                                   [[Options sharedOptions] strength]]];
               [engineController commitCommands];
            }

            // Start thinking.
            engineIsPlaying = YES;
            [engineController sendCommand: [game uciGameString]];
            if ([[Options sharedOptions] isFixedTimeLevel])
               [engineController
                  sendCommand: [NSString stringWithFormat: @"go movetime %d",
                                         [[Options sharedOptions] timeIncrement]]];
              [engineController commitCommands];
         }
      }
   }
}


- (void)engineGoPonder:(Move)pMove {

   if (![game positionIsTerminal] && ![game positionAfterMoveIsTerminal: pMove]) {
      assert(engineIsPlaying);
      assert((gameMode==GAME_MODE_COMPUTER_BLACK && [game sideToMove]==WHITE) ||
             (gameMode==GAME_MODE_COMPUTER_WHITE && [game sideToMove]==BLACK));
      assert(pMove != MOVE_NONE);

      // Start thinking.
      engineIsPlaying = YES;
      [engineController
         sendCommand:
            [NSString stringWithFormat: @"%@ %s",
                      [game uciGameString], move_to_string(pMove).c_str()]];
      isPondering = YES;
      [engineController commitCommands];
   }
}


/// engineMadeMove: is called by the engine controller whenever the engine
/// makes a move.  The input is an NSArray which is assumed to consist of two
/// NSStrings, representing a move and a ponder move.  The reason we stuff the
/// move strings into an array is that the method is called from another thread,
/// using the performSelectorOnMainThread:withObject:waitUntilDone: method,
/// and this method can only pass a single argument to the selector.

- (void)engineMadeMove:(NSArray *)array {
   if (!engineIsPlaying) {
      return;
   }

   assert([array count] <= 2);
   Move m = [game moveFromString:array[0]];
   assert(m != MOVE_NONE);
   [game setHintForCurrentPosition: m];
   [self playMoveSound: [game pieceOn: move_from(m)]
               capture: [game pieceOn: move_to(m)] != EMPTY];
   [self doEngineMove: m];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopActivityIndicator" object:nil];
   if ([array count] == 2 && ![array[1] isEqualToString:@"(none)"]) {
      ponderMove = [game moveFromString:array[1]];
      [game setHintForCurrentPosition: ponderMove];
      if ([[Options sharedOptions] permanentBrain])
         [self engineGoPonder: ponderMove];
   }
   [self gameEndTest];
}


- (BOOL)usersTurnToMove {
   return
      gameMode == GAME_MODE_TWO_PLAYER ||
      gameMode == GAME_MODE_ANALYSE ||
      (gameMode == GAME_MODE_COMPUTER_BLACK && [game sideToMove] == WHITE) ||
      (gameMode == GAME_MODE_COMPUTER_WHITE && [game sideToMove] == BLACK);
}


- (BOOL)computersTurnToMove {
   return ![self usersTurnToMove];
}


- (void)engineMoveNow {
   NSLog(@"GameController engineMoveNow");
   if ([self computersTurnToMove]) {
      [engineController abortSearch];
      [engineController commitCommands];
   }
}


- (void)gameEndTest {
   if ([game positionIsMate]) {
      [[[UIAlertView alloc] initWithTitle: (([game sideToMove] == WHITE)?
                                             @"Black wins" : @"White wins")
                                   message: @"CHECKMATE"
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
         show];
      [game setResult: (([game sideToMove] == WHITE)? @"0-1" : @"1-0")];
   } else if ([game positionIsDraw]) {
      [[[UIAlertView alloc] initWithTitle: @"DRAW"
                                   message: [game drawReason]
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
         show];
      [game setResult: @"1/2-1/2"];
   }
}


- (void)loadPieceImages {
   for (Piece p = WP; p <= BK; p++)
      ;
   static NSString *pieceImageNames[16] = {
      nil, @"WPawn", @"WKnight", @"WBishop", @"WRook", @"WQueen", @"WKing", nil,
      nil, @"BPawn", @"BKnight", @"BBishop", @"BRook", @"BQueen", @"BKing", nil
   };
   NSString *pieceSet = [[Options sharedOptions] pieceSet];
   for (Piece p = WP; p <= BK; p++) {
      if (piece_is_ok(p)) {
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            pieceImages[p] =
               [UIImage imageNamed: [NSString stringWithFormat: @"%@%@96.png",
                                               pieceSet, pieceImageNames[p]]];
         else
            pieceImages[p] =
               [UIImage imageNamed: [NSString stringWithFormat: @"%@%@.png",
                                               pieceSet, pieceImageNames[p]]];
      }
      else
         pieceImages[p] = nil;
   }
}


- (void)pieceSetChanged:(NSNotification *)aNotification {
   [self loadPieceImages];
   for (Square sq = SQ_A1; sq <= SQ_H8; sq++) {
      Square s = [self rotateSquare: sq];
      if ([self pieceOn: s] != EMPTY) {
         PieceImageView *piv = [self pieceImageViewForSquare: sq];
         [piv setImage: pieceImages[[self pieceOn: s]]];
         [piv setNeedsDisplay];
      }
   }
}


- (void)gameFromPGNString:(NSString *)pgnString
        loadFromBeginning:(BOOL)fromBeginning {
   for (PieceImageView *piv in pieceViews)
      [piv removeFromSuperview];

   @try {
      game = [[Game alloc] initWithGameController: self PGNString: pgnString];
   }
   @catch (NSException *e) {
      NSLog(@"Exception while parsing stored game: %@", [e reason]);
      NSLog(@"game:\n%@", pgnString);
      game = [[Game alloc] initWithGameController: self];
   }

   if (fromBeginning)
      [game toBeginning];

   gameLevel = [[Options sharedOptions] gameLevel];
   gameMode = [[Options sharedOptions] gameMode];
   pieceViews = [[NSMutableArray alloc] init];
   pendingFrom = SQ_NONE;
   pendingTo = SQ_NONE;

   [self showPiecesAnimate: NO];
   [self updateMoveList];
   [self showBookMoves];

   engineIsPlaying = NO;
   [engineController abortSearch];
   [engineController sendCommand: @"ucinewgame"];
   [engineController commitCommands];
   if (gameMode == GAME_MODE_ANALYSE)
      [self engineGo];
}


- (void)gameFromFEN:(NSString *)fen {
   for (PieceImageView *piv in pieceViews)
      [piv removeFromSuperview];

   game = [[Game alloc] initWithGameController: self FEN: fen];
   gameLevel = [[Options sharedOptions] gameLevel];
   gameMode = [[Options sharedOptions] gameMode];
   pieceViews = [[NSMutableArray alloc] init];
   pendingFrom = SQ_NONE;
   pendingTo = SQ_NONE;

   [self showPiecesAnimate: NO];
   [moveListView setText: [game htmlString]
             scrollToPly: [game currentMoveIndex]];
   [self showBookMoves];

   engineIsPlaying = NO;
   [engineController abortSearch];
   [engineController sendCommand: @"ucinewgame"];
   [engineController commitCommands];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey: @"rotateBoard"])
        [self rotateBoard: [defaults boolForKey: @"rotateBoard"] animate: NO];

   [self engineGo];
   if (gameMode == GAME_MODE_ANALYSE)
      [self engineGo];
}


// checkPasteboard inspects the contents of the pasteboard. If it looks like a game in PGN
// notation or a FEN, offer to import it.
- (void)checkPasteboard {
   NSString *string = [[UIPasteboard generalPasteboard] string];
   if (string) {
      Game *g;
      @try {
         g = [[Game alloc] initWithGameController: nil PGNString: string];
         [self offerToLoadGameFromPasteboard];
      }
      @catch (NSException *e) {
         // OK doesn't look like a game. Perhaps it's a FEN string?
         if (Position::is_valid_fen([string UTF8String])) {
            [self offerToLoadPositionFromPasteboard];
         } else {
            NSLog(@"Sorry, I couldn't make sense of the pasteboard, giving up.");
         }
      }
   }
}

- (void)offerToLoadGameFromPasteboard {
   [[[UIAlertView alloc] initWithTitle: @"Import game?"
                                message: @"The clipboard contents look like a chess game. Would you like to import it?"
                               delegate: self
                      cancelButtonTitle: nil
                      otherButtonTitles: @"Yes", @"No", nil]
    show];
}

- (void)offerToLoadPositionFromPasteboard {
   [[[UIAlertView alloc] initWithTitle: @"Import position?"
                                message: @"The clipboard contents look like a chess position. Would you like to import it?"
                               delegate: self
                      cancelButtonTitle: nil
                      otherButtonTitles: @"Yes", @"No", nil]
    show];
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if ([[alertView title] isEqualToString: @"Import game?"]) {
      if (buttonIndex == 0) {
         [self gameFromPGNString: [[UIPasteboard generalPasteboard] string]
               loadFromBeginning: YES];
         [[UIPasteboard generalPasteboard] setString: @""];
      }
   } else if ([[alertView title] isEqualToString: @"Import position?"]) {
      if (buttonIndex == 0) {
         [self gameFromFEN:
          [[[UIPasteboard generalPasteboard] string]
           stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
         [[UIPasteboard generalPasteboard] setString: @""];
      }
   }
}


- (void)showBookMoves {
   if ([[Options sharedOptions] showBookMoves]) {
      NSString *s = [game bookMovesAsString];
      if (s)
         [bookMovesView setText: [NSString stringWithFormat: @"  Book: %@",
                                           [game bookMovesAsString]]];
      else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         [bookMovesView setText: @"  Book:"];
      else if ([[bookMovesView text] hasPrefix: @"  Book:"])
         [bookMovesView setText: @""];
   } else if ([[bookMovesView text] hasPrefix: @"  Book:"]) {
      [bookMovesView setText:@""];
   }
}


- (void)changePlayStyle {
}


- (void)startThinking {
   if ([game sideToMove] == WHITE) {
      [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
      [self setGameMode: GAME_MODE_COMPUTER_WHITE];
   } else {
      [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_BLACK];
      [self setGameMode: GAME_MODE_COMPUTER_BLACK];
   }
}


- (BOOL)engineIsThinking {
   return [engineController engineIsThinking];
}


- (void)piecesSetUserInteractionEnabled:(BOOL)enable {
   for (PieceImageView *piv in pieceViews)
      [piv setUserInteractionEnabled: enable];
}


- (void)redrawPieces {
   NSLog(@"preparing to redraw pieces");
   [boardView setRotated: rotated];
   for (PieceImageView *piv in pieceViews)
      [piv removeFromSuperview];
   pieceViews = [[NSMutableArray alloc] init];
   [self showPiecesAnimate: NO];
}


- (void)webViewDidFinishLoad:(UIWebView *)view {
   [moveListView setText: [game htmlString]
             scrollToPly: [game currentMoveIndex]];
}


-(BOOL)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)type {
   NSString *string = [[[request URL] absoluteString] lowercaseString];

   if ([string hasPrefix: @"jumptoply:"]) {
      NSInteger ply;
      [[NSScanner scannerWithString:
            [string componentsSeparatedByString:@":"][1]]
         scanInteger: &ply];
      [self jumpToPly: (int)ply + 1 animate: YES];
      return NO;
   } else if ([string hasPrefix: @"navigate:"]) {
      NSString *direction = [string componentsSeparatedByString:@":"][1];
      if ([direction isEqualToString: @"back"])
         [self takeBackMove];
      else if ([direction isEqualToString: @"forward"])
         [self replayMove];
   } else if ([string hasPrefix: @"log:"]) {
      NSLog(@"%@", [string componentsSeparatedByString:@":"][1]);
      return NO;
   }
   return YES;
}


- (void)dealloc {
   NSLog(@"GameController dealloc");
   [engineController quit];
    // Should we remove them from superview first??
   [[NSNotificationCenter defaultCenter] removeObserver: self];

   //while ([engineController engineThreadIsRunning]);

}


@end
