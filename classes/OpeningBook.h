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

#include "../Chess/position.h"

using namespace Chess;

@interface OpeningBook : NSObject {
   FILE *file;
   int size;
   uint64_t firstKey, lastKey;
}

- (id)initWithFilename:(NSString *)filename;
- (void)close;
- (Move)pickMoveForPosition:(Position *)position;
- (void)allMovesForPosition:(Position *)position toArray:(Move *)array;
- (NSString *)bookMovesAsString:(Position *)position;

@end
