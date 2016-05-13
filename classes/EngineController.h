/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
