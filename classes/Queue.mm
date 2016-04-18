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

#import "Queue.h"


@implementation Queue

- (id)init {
   if (self = [super init]) {
      contents = [[NSMutableArray alloc] init];
   }
   return self;
}

- (BOOL)isEmpty {
   return [self size] == 0;
}

- (int)size {
   return (int)[contents count];
}

- (id)front {
   return [contents objectAtIndex: 0];
}

- (id)back {
   return [contents lastObject];
}

- (void)push:(id)anObject {
   [contents addObject: anObject];
}

- (id)pop {
   id object = nil;
   if (![self isEmpty]) {
      object = [contents objectAtIndex: 0];
      [contents removeObjectAtIndex: 0];
   }
   else
      NSLog(@"Queue undeflow!");

   return object;
}


@end
