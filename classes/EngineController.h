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

#import <Foundation/Foundation.h>

#import "Queue.h"

@class GameController;

@interface EngineController : NSObject {
   Queue *commandQueue;
   GameController *gameController;
   pthread_cond_t WaitCondition;
   pthread_mutex_t WaitConditionLock;
   BOOL ignoreBestmove;
   BOOL engineThreadShouldStop;
   BOOL engineThreadIsRunning;
   BOOL engineIsThinking;
}

@property (nonatomic, readonly) BOOL engineIsThinking;
@property (nonatomic, readonly) BOOL engineThreadIsRunning;

- (id)initWithGameController:(GameController *)gc;
- (void)startEngine:(id)anObject;
- (void)sendCommand:(NSString *)command;
- (void)abortSearch;
- (void)commitCommands;
- (BOOL)commandIsWaiting;
- (NSString *)getCommand;
- (void)sendPV:(NSString *)pv depth:(int)depth score:(int)score scoreType:(int)scoreType mate:(BOOL)mate;
- (void)sendCurrentMove:(NSString *)currmove
      currentMoveNumber:(int)currmovenum
          numberOfMoves:(int)movenum
                  depth:(int)depth
                   time:(long)time
                  nodes:(int64_t)nodes;
- (void)sendBestMove:(NSString *)bestMove ponderMove:(NSString *)ponderMove;
- (void)ponderhit;
- (void)pondermiss;
- (void)quit;
- (BOOL)engineIsThinking;
- (void)setOption:(NSString *)name value:(NSString *)value;
- (void)setPlayStyle:(NSString *)style;

@end

extern EngineController *GlobalEngineController; // HACK
