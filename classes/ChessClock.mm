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

#import "ChessClock.h"

#include "../Chess/misc.h"


@implementation ChessClock

@synthesize isRunning, whiteInitialTime, blackInitialTime,
   whiteIncrement, blackIncrement;


+ (int)currentSystemTime {
   return Chess::get_system_time();
}

+ (NSString *)prettyTimeString:(int)msecs {
   int seconds = msecs / 1000;
   int minutes = seconds / 60;
   int hours = minutes / 60;
   char str[256], str2[10];

   if (hours) {
      sprintf(str, "%d:", hours);
      if ((minutes % 60) < 10) strcat(str, "0");
   }
   else
      strcpy(str, "");
   sprintf(str2, "%d:", minutes % 60);
   if ((seconds % 60) < 10) strcat(str2, "0");
   strcat(str, str2);
   sprintf(str2, "%d", seconds % 60);
   strcat(str, str2);
   return [NSString stringWithUTF8String: str];
}


- (id)initWithTime:(int)time
	 increment:(int)inc
    whiteClockView:(UILabel *)wcv
    blackClockView:(UILabel *)bcv {
   if (self = [super init]) {

      whiteInitialTime = blackInitialTime = time;
      whiteIncrement = blackIncrement = inc;
      whiteConsumedTime = blackConsumedTime = 0;
      whiteAccumulatedIncrement = blackAccumulatedIncrement = 0;
      isRunning = NO;
      lastStartTime = 0;
      whiteNumOfMoves = blackNumOfMoves = 0;
      fixedTime = NO;
      whiteClockView = wcv;
      blackClockView = bcv;
      timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                target: self
                                              selector: @selector(timerWasFired:)
                                              userInfo: nil
                                               repeats: YES];
      [whiteClockView setTextColor: [UIColor blackColor]];
      [whiteClockView setText:
                         [NSString stringWithFormat: @"White: %@",
                                   [self whiteRemainingTimeString]]];
      [blackClockView setTextColor: [UIColor blackColor]];
      [blackClockView setText:
                         [NSString stringWithFormat: @"Black: %@",
                                   [self blackRemainingTimeString]]];
   }
   return self;
}


- (id)initWithTime:(int)time
	  forMoves:(int)mps
    whiteClockView:(UILabel *)wcv
    blackClockView:(UILabel *)bcv {
   if (self = [super init]) {
      whiteInitialTime = blackInitialTime = time;
      whiteNumOfMoves = blackNumOfMoves = mps;
      whiteIncrement = blackIncrement = 0;
      whiteConsumedTime = blackConsumedTime = 0;
      whiteAccumulatedIncrement = blackAccumulatedIncrement = 0;
      isRunning = NO;
      lastStartTime = 0;
      fixedTime = NO;
      whiteClockView = wcv;
      blackClockView = bcv;
      timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                target: self
                                              selector: @selector(timerWasFired:)
                                              userInfo: nil
                                               repeats: YES];
      [whiteClockView setText:
                         [NSString stringWithFormat: @"White: %@",
                                   [self whiteRemainingTimeString]]];
      [blackClockView setText:
                         [NSString stringWithFormat: @"Black: %@",
                                   [self blackRemainingTimeString]]];
   }
   return self;
}


- (void)resetWithTime:(int)time increment:(int)inc {
   whiteInitialTime = blackInitialTime = time;
   whiteIncrement = blackIncrement = inc;
   whiteConsumedTime = blackConsumedTime = 0;
   whiteAccumulatedIncrement = blackAccumulatedIncrement = 0;
   fixedTime = NO;
   [whiteClockView setTextColor: [UIColor blackColor]];
   [whiteClockView setText:
                      [NSString stringWithFormat: @"White: %@",
                                [self whiteRemainingTimeString]]];
   [blackClockView setTextColor: [UIColor blackColor]];
   [blackClockView setText:
                      [NSString stringWithFormat: @"Black: %@",
                                [self blackRemainingTimeString]]];
}


- (void)resetWithTime:(int)time forMoves:(int)mps {
   whiteInitialTime = blackInitialTime = time;
   whiteNumOfMoves = blackNumOfMoves = mps;
   whiteIncrement = blackIncrement = 0;
   fixedTime = NO;
   [whiteClockView setTextColor: [UIColor blackColor]];
   [whiteClockView setText:
                      [NSString stringWithFormat: @"White: %@",
                                [self whiteRemainingTimeString]]];
   [blackClockView setTextColor: [UIColor blackColor]];
   [blackClockView setText:
                      [NSString stringWithFormat: @"Black: %@",
                                [self blackRemainingTimeString]]];
}


- (void)resetWithFixedTime:(int)time {
   fixedTime = YES;
   [whiteClockView setTextColor: [UIColor blackColor]];
   [whiteClockView setText:
                      [NSString stringWithFormat: @"White: %@",
                                [self whiteRemainingTimeString]]];
   [blackClockView setTextColor: [UIColor blackColor]];
   [blackClockView setText:
                      [NSString stringWithFormat: @"Black: %@",
                                [self blackRemainingTimeString]]];
}


-(int)whiteRemainingTime {
   if (fixedTime) {
      if (isRunningForWhite)
         return whiteConsumedTime + [ChessClock currentSystemTime] - lastStartTime;
      else
         return whiteConsumedTime;
   }
   int result = whiteInitialTime - whiteConsumedTime + whiteAccumulatedIncrement;
   if (isRunningForWhite)
      result -= [ChessClock currentSystemTime] - lastStartTime;
   if (result < 0) result = 0;
   return result;
}


-(int)blackRemainingTime {
   if (fixedTime) {
      if (isRunningForBlack)
         return blackConsumedTime + [ChessClock currentSystemTime] - lastStartTime;
      else
         return blackConsumedTime;
   }
   int result = blackInitialTime - blackConsumedTime + blackAccumulatedIncrement;
   if (isRunningForBlack)
      result -= [ChessClock currentSystemTime] - lastStartTime;
   if (result < 0) result = 0;
   return result;
}


-(NSString *)whiteRemainingTimeString {
   return [ChessClock prettyTimeString: [self whiteRemainingTime]];
}


-(NSString *)blackRemainingTimeString {
   return [ChessClock prettyTimeString: [self blackRemainingTime]];
}


- (void)startClockForWhite {
   if (!isRunning) {
      lastStartTime = [ChessClock currentSystemTime];
      isRunning = YES;
      isRunningForWhite = YES;
      isRunningForBlack = NO;
   }
}


- (void)startClockForBlack {
   if (!isRunning) {
      lastStartTime = [ChessClock currentSystemTime];
      isRunning = YES;
      isRunningForWhite = NO;
      isRunningForBlack = YES;
   }
}


- (void)stopClock {
   if (isRunning) {
      [self pushClock];
      isRunning = isRunningForWhite = isRunningForBlack = NO;
   }
}


- (void)pushClock {
   if (isRunning) {
      int currentTime = [ChessClock currentSystemTime];
      int consumedTime = currentTime - lastStartTime;
      if (isRunningForWhite) {
         whiteConsumedTime += consumedTime;
         whiteAccumulatedIncrement += whiteIncrement;
         if (whiteNumOfMoves) {
            whiteRemainingMoves--;
            if (whiteRemainingMoves == 0)
               whiteAccumulatedIncrement += whiteInitialTime;
         }
         isRunningForWhite = NO;
         isRunningForBlack = YES;
         [whiteClockView setText:
                            [NSString stringWithFormat: @"White: %@",
                                      [self whiteRemainingTimeString]]];
      }
      else {
         blackConsumedTime += consumedTime;
         blackAccumulatedIncrement += blackIncrement;
         if (blackNumOfMoves) {
            blackRemainingMoves--;
            if (blackRemainingMoves == 0)
               blackAccumulatedIncrement += blackInitialTime;
         }
         isRunningForWhite = YES;
         isRunningForBlack = NO;
         [blackClockView setText:
                            [NSString stringWithFormat: @"Black: %@",
                                      [self blackRemainingTimeString]]];
      }
      lastStartTime = currentTime;
   }
}


- (void)addTimeForWhite:(int)msecs {
   whiteInitialTime += msecs;
   [whiteClockView setText: [NSString stringWithFormat: @"White: %@",
                                      [self whiteRemainingTimeString]]];
}


- (void)addTimeForBlack:(int)msecs {
   blackInitialTime += msecs;
   [blackClockView setText: [NSString stringWithFormat: @"Black: %@",
                                      [self blackRemainingTimeString]]];
}


- (void)timerWasFired:(NSTimer *)t {
   if (isRunningForWhite) {
      if ([self whiteRemainingTime] <= 0 && !fixedTime)
         [whiteClockView setTextColor: [UIColor redColor]];
      [whiteClockView setText:
                         [NSString stringWithFormat: @"White: %@",
                                   [self whiteRemainingTimeString]]];
   }
   else if (isRunningForBlack) {
      if ([self blackRemainingTime] <= 0 && !fixedTime)
         [blackClockView setTextColor: [UIColor redColor]];
      [blackClockView setText:
                         [NSString stringWithFormat: @"Black: %@",
                                   [self blackRemainingTimeString]]];
   }
}


- (void)stopTimer {
   [timer invalidate];
}


- (void)dealloc {
   NSLog(@"ChessClock dealloc");
}


@end
