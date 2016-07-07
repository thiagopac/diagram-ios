/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

#import "BoardView.h"
#import "Game.h"
#import "Options.h"

@class EngineController;
@class MoveListView;
@class LastMoveView;
@class PieceImageView;

@interface GameController : NSObject <UIActionSheetDelegate> {
   EngineController *engineController;
   BoardView *boardView;
   UILabel *analysisView, *bookMovesView, *__weak whiteClockView, *__weak blackClockView, *__weak searchStatsView;
   MoveListView *moveListView;
   Game *game;
   NSMutableArray *pieceViews;
   UIImage *pieceImages[16];
   Square pendingFrom, pendingTo; // HACK for handling promotions.
   BOOL rotated;
   SystemSoundID pieceSounds[7][2];
   SystemSoundID captureSounds[8];
   NSTimer *timer;
   GameLevel gameLevel;
   GameMode gameMode;
   Move ponderMove;
   BOOL engineIsPlaying;
   BOOL isPondering;
   LastMoveView *lastMoveView;
   NSString *strImgQUEEN;
   NSString *strImgROOK;
   NSString *strImgKNIGHT;
   NSString *strImgBISHOP;
    
}

@property (weak, nonatomic, readonly) UILabel *whiteClockView;
@property (weak, nonatomic, readonly) UILabel *blackClockView;
@property (weak, nonatomic, readonly) UILabel *searchStatsView;
@property (nonatomic, readonly) Game *game;
@property (nonatomic, assign) GameMode gameMode;
@property (nonatomic, readonly) BOOL rotated;


- (id)initWithBoardView:(BoardView *)bv
           moveListView:(MoveListView *)mlv
           analysisView:(UILabel *)av
          bookMovesView:(UILabel *)bmv
        searchStatsView:(UILabel *)ssv;
- (void)startEngine;
- (void)startNewGame;
- (void)updateMoveList;
- (BOOL)moveIsPending;
- (Piece)pieceOn:(Square)sq;
- (BOOL)pieceCanMoveFrom:(Square)sq;
- (int)pieceCanMoveFrom:(Square)fSq to:(Square)tSq;
- (int)destinationSquaresFrom:(Square)sq saveInArray:(Square *)sqs;
- (void)doMoveFrom:(Square)fSq to:(Square)tSq promotion:(PieceType)prom;
- (void)animateMoveFrom:(Square)fSq to:(Square)tSq;
- (void)removePieceOn:(Square)sq;
- (void)putPiece:(Piece)p on:(Square)sq;
- (void)animateMove:(Move)m;
- (void)takeBackMovesFrom:(int)fromPly to:(int)toPly current:(int)currentPly;
- (void)replayMovesFrom:(int)fromPly to:(int)toPly current:(int)currentPly;
- (void)takeBackMove;
- (void)replayMove;
- (void)takeBackAllMoves;
- (void)replayAllMoves;
- (void)jumpToPly:(int)ply animate:(BOOL)animate;
- (void)showPiecesAnimate:(BOOL)animate;
- (PieceImageView *)pieceImageViewForSquare:(Square)sq;
- (void)rotateBoardAnimate:(BOOL)animate;
- (void)rotateBoard;
- (void)rotateBoard:(BOOL)rotate animate:(BOOL)animate;
- (void)rotateBoard:(BOOL)rotate;
- (void)showHint;
- (NSString *)emailPgnString;
- (void)playMoveSound:(Piece)p capture:(BOOL)capture;
- (void)displayPV:(NSString *)pv
            depth:(int)depth
            score:(int)score
        scoreType:(int)scoreType
             mate:(BOOL)mate;
- (void)displayCurrentMove:(NSString *)currentMove
         currentMoveNumber:(int)currentMoveNumber
             numberOfMoves:(int)totalMoveCount
                     depth:(int)depth
                      time:(long)time
                     nodes:(int64_t)nodes;
- (void)setGameLevel:(GameLevel)newGameLevel;
- (void)setGameMode:(GameMode)newGameMode;
- (void)doEngineMove:(Move)m;
- (void)engineGo;
- (void)engineGoPonder:(Move)pMove;
- (void)engineMadeMove:(NSArray *)array;
- (BOOL)usersTurnToMove;
- (BOOL)computersTurnToMove;
- (void)engineMoveNow;
- (void)gameEndTest;
- (void)loadPieceImages;
- (void)pieceSetChanged:(NSNotification *)aNotification;
- (void)gameFromPGNString:(NSString *)pgnString loadFromBeginning:(BOOL)fromBeginning;
- (void)gameFromFEN:(NSString *)fen;
- (void)showBookMoves;
- (void)changePlayStyle;
- (void)startThinking;
- (BOOL)engineIsThinking;
- (void)piecesSetUserInteractionEnabled:(BOOL)enable;
- (void)redrawPieces;
- (void)webViewDidFinishLoad:(UIWebView *)view;
- (void)checkPasteboard;
- (void)offerToLoadGameFromPasteboard;
- (void)offerToLoadPositionFromPasteboard;

@end
