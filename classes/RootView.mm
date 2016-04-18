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

#import "RootView.h"


@implementation RootView


- (id)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame:frame]) {
      // Initialization code
   }
   return self;
}


- (void)drawRect:(CGRect)rect {
   // Drawing code
}


- (void)flipSubviewsLeft {
   CGContextRef context = UIGraphicsGetCurrentContext();
   [UIView beginAnimations: nil context: context];
   [UIView setAnimationTransition: UIViewAnimationTransitionCurlUp /*UIViewAnimationTransitionFlipFromLeft*/
                          forView: self cache: YES];
   [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDuration: 0.5];
   [self exchangeSubviewAtIndex: 0 withSubviewAtIndex: 1];
   [UIView commitAnimations];
}


- (void)flipSubviewsRight {
   CGContextRef context = UIGraphicsGetCurrentContext();
   [UIView beginAnimations: nil context: context];
   [UIView setAnimationTransition: UIViewAnimationTransitionCurlDown /*UIViewAnimationTransitionFlipFromRight*/
                          forView: self cache: YES];
   [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDuration: 0.5];
   [self exchangeSubviewAtIndex: 0 withSubviewAtIndex: 1];
   [UIView commitAnimations];
}



@end
