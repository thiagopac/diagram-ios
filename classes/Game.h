/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <Foundation/Foundation.h>

#import "ChessClock.h"
#import "ChessMove.h"
#import "OpeningBook.h"

#include "../Chess/position.h"

using namespace Chess;

#define HINT_HASH_TABLE_SIZE 1024

typedef struct {
   uint64_t key;
   Move move;
} HintHashentry;

@class GameController;

@interface Game : NSObject {
   GameController *gameController;
   NSString *startFEN;
   Position *startPosition;
   Position *currentPosition;
   NSMutableArray *moves;
   int currentMoveIndex;
   OpeningBook *book;
   ChessClock *clock;

   NSString *event;
   NSString *site;
   NSString *date;
   NSString *round;
   NSString *whitePlayer;
   NSString *blackPlayer;
   NSString *result;
   
   NSString *eco;
   NSString *opening;
   NSString *variation;

   NSString *openingString;

   HintHashentry hintHashTable[HINT_HASH_TABLE_SIZE];
}

@property (nonatomic, readonly) ChessClock *clock;
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *round;
@property (nonatomic, strong) NSString *whitePlayer;
@property (nonatomic, strong) NSString *blackPlayer;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSString *eco;
@property (nonatomic, strong) NSString *opening;
@property (nonatomic, strong) NSString *variation;
@property (nonatomic, strong) NSString *openingString;
@property (nonatomic, readonly) int currentMoveIndex;
@property (nonatomic, readonly) Position *startPosition;
@property (nonatomic, readonly) NSArray *moves;

- (id)initWithGameController:(GameController *)gc FEN:(NSString *)fen;
- (id)initWithGameController:(GameController *)gc PGNString:(NSString *)string;
- (id)initWithGameController:(GameController *)gc;
- (Color)sideToMove;
- (Piece)pieceOn:(Square)sq;
- (BOOL)pieceCanMoveFrom:(Square)sq;
- (int)pieceCanMoveFrom:(Square)fSq to:(Square)tSq;
- (int)generateLegalMoves:(Move *)mlist;
- (int)movesFrom:(Square)sq saveInArray:(Move *)mlist;
- (int)destinationSquaresFrom:(Square)sq saveInArray:(Square *)sqs;
- (void)doMove:(Move)m;
- (Move)doMoveFrom:(Square)fSq to:(Square)tSq promotion:(PieceType)prom;
- (void)doMoveFrom:(Square)fSq to:(Square)tSq;
- (BOOL)atBeginning;
- (BOOL)atEnd;
- (void)takeBack;
- (void)stepForward;
- (void)toBeginning;
- (void)toEnd;
- (void)toPly:(int)ply;
- (ChessMove *)previousMove;
- (ChessMove *)nextMove;
- (NSString *)moveToSAN:(Move)move;
- (NSString *)moveListString;
- (NSString *)partialMoveListString;
- (NSString *)pgnString;
- (NSString *)emailPgnString;
- (NSString *)uciGameString;
- (NSString *)htmlString;
- (Move)getBookMove;
- (void)getAllBookMoves:(Move *)moveArray;
- (NSString *)bookMovesAsString;
- (Move)moveFromString:(NSString *)string;
- (void)startClock;
- (void)stopClock;
- (void)pushClock;
- (int)whiteRemainingTime;
- (int)blackRemainingTime;
- (NSString *)whiteClockString;
- (NSString *)blackClockString;
- (void)setTimeControlWithTime:(int)time increment:(int)increment;
- (void)setTimeControlWithTime:(int)time movesPerSession:(int)mps;
- (void)setTimeControlWithFixedTime:(int)time;
- (void)setHintForCurrentPosition:(Move)hintMove;
- (Move)getHintForCurrentPosition;
- (BOOL)positionIsMate;
- (BOOL)positionIsDraw;
- (NSString *)drawReason;
- (BOOL)positionIsTerminal;
- (BOOL)positionAfterMoveIsTerminal:(Move)m;
- (void)addComment: (NSString *)comment;
- (Move)currentMove;
- (NSString *)currentFEN;
- (NSArray *)moveList;
- (uint64_t)keyForCurrentPosition;
- (void)computeOpeningString;
- (NSString *)prettyPV:(NSString *)pv
                 depth:(int)depth
                 score:(int)score
             scoreType:(int)scoreType
                  mate:(BOOL)mate;

@end
