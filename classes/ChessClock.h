/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@interface ChessClock : NSObject {
   int whiteInitialTime, blackInitialTime;
   int whiteIncrement, blackIncrement;
   int whiteConsumedTime, blackConsumedTime;
   int whiteAccumulatedIncrement, blackAccumulatedIncrement;
   int whiteNumOfMoves, blackNumOfMoves;
   int whiteRemainingMoves, blackRemainingMoves;
   BOOL isRunning, isRunningForWhite, isRunningForBlack;
   int lastStartTime;
   UILabel *whiteClockView, *blackClockView;
   NSTimer *timer;
   BOOL fixedTime;
}

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, assign) int whiteInitialTime;
@property (nonatomic, assign) int blackInitialTime;
@property (nonatomic, assign) int whiteIncrement;
@property (nonatomic, assign) int blackIncrement;

+ (int)currentSystemTime;
+ (NSString *)prettyTimeString:(int)msecs;
- (id)initWithTime:(int)time
	 increment:(int)inc
    whiteClockView:(UILabel *)wcv
    blackClockView:(UILabel *)bcv;
- (id)initWithTime:(int)time
	  forMoves:(int)mps
    whiteClockView:(UILabel *)wcv
    blackClockView:(UILabel *)bcv;
- (void)resetWithTime:(int)time increment:(int)inc;
- (void)resetWithTime:(int)time forMoves:(int)mps;
- (void)resetWithFixedTime:(int)time;
- (int)whiteRemainingTime;
- (int)blackRemainingTime;
- (NSString *)whiteRemainingTimeString;
- (NSString *)blackRemainingTimeString;
- (void)startClockForWhite;
- (void)startClockForBlack;
- (void)stopClock;
- (void)pushClock;
- (void)addTimeForWhite:(int)msecs;
- (void)addTimeForBlack:(int)msecs;
- (void)timerWasFired:(NSTimer *)timer;
- (void)stopTimer;


@end
