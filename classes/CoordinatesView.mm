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

#import "CoordinatesView.h"


@implementation CoordinatesView

@dynamic isFlipped;


- (id)initWithFrame:(CGRect)frame flipped:(BOOL)flipped {
   if (self = [super initWithFrame: frame]) {
      sqSize = frame.size.width / 8;
      [self setUserInteractionEnabled: NO];
      for (int i = 0; i < 8; i++) {
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fileLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake((i+1)*sqSize - 11.0,
                                                          8*sqSize - 15.0,
                                                          13.0, 15.0)];
            [fileLabels[i] setFont: [UIFont systemFontOfSize: 14.0f]];
            rankLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake(2.0,
                                                          i*sqSize + 2.0,
                                                          13.0, 15.0)];
            [rankLabels[i] setFont: [UIFont systemFontOfSize: 14.0f]];
         }
         else {
            fileLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake((i+1)*sqSize - 7.0,
                                                          8*sqSize - 12.0,
                                                          10.0, 12.0)];
            [fileLabels[i] setFont: [UIFont systemFontOfSize: 11.0f]];
            rankLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake(2.0,
                                                          i*sqSize + 2.0,
                                                          10.0, 12.0)];
            [rankLabels[i] setFont: [UIFont systemFontOfSize: 11.0f]];
         }
         [fileLabels[i] setTextColor: [UIColor blackColor]];
         [fileLabels[i] setBackgroundColor: [UIColor clearColor]];
         [self addSubview: fileLabels[i]];

         [rankLabels[i] setTextColor: [UIColor blackColor]];
         [rankLabels[i] setBackgroundColor: [UIColor clearColor]];
         [self addSubview: rankLabels[i]];

         [self setIsFlipped: flipped];
      }
   }
   return self;
}

- (void)dealloc {
   NSLog(@"CoordinatesView dealloc");
}


- (BOOL)isFlipped {
   return isFlipped;
}

- (void)setIsFlipped:(BOOL)flip {
   isFlipped = flip;
   for (int i = 0; i < 8; i++) {
      [fileLabels[i]
          setText: [NSString stringWithFormat: @"%c",
                         (char)((flip? (7-i) : i) + 'a')]];
      [rankLabels[i]
          setText: [NSString stringWithFormat: @"%c",
                             (char)((flip? i : (7-i)) + '1')]];
   }
}


@end
