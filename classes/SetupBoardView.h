/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#include "../Chess/bitboard.h"
#include "../Chess/piece.h"
#include "../Chess/square.h"

using namespace Chess;

@class HighlightedSquaresView;
@class SelectedPieceView;
@class SelectedSquareView;

enum SetupPhase {
   PHASE_EDIT_BOARD,
   PHASE_EDIT_STM,
   PHASE_EDIT_CASTLES,
   PHASE_EDIT_EP
};

@interface SetupBoardView : UIView {
   UIColor *darkSquareColor, *lightSquareColor;
   UIImage *darkSquareImage, *lightSquareImage;
   id controller;
   Piece board[64];
   NSMutableArray *pieceViews;
   UIImage *pieceImages[16];
   SelectedPieceView *__weak selectedPieceView;
   SelectedSquareView *selectedSquareView;
   Square selectedSquare;
   Bitboard bitboards[2][16];
   SetupPhase phase;
   NSString *startFen;
   HighlightedSquaresView *highlightedSquaresView;
   Square epSquares[8];
   float sqSize;
}

@property (nonatomic, weak) SelectedPieceView *selectedPieceView;

- (id)initWithController:(id)c
                   frame:(CGRect)frame
                     fen:(NSString *)fen
                   phase:(SetupPhase)aPhase;
- (void)putPiece:(Piece)p onSquare:(Square)s;
- (void)removePieceOnSquare:(Square)s;
- (void)clear;
- (BOOL)pieceCountsOK;
- (int)whiteIsInCheck;
- (int)blackIsInCheck;
- (NSString *)boardString;
- (NSString *)maybeCastleString;
- (int)epCandidateSquares:(Square *)squares;
- (int)epCandidateSquaresForColor:(Color)us toArray:(Square *)squares;
- (NSString *)fen;

@end
