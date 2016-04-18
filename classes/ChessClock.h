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
