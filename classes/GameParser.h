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

#define PGN_STRING_SIZE 256

enum {
   TOKEN_ERROR = -1,
   TOKEN_EOF = 256,
   TOKEN_SYMBOL = 257,
   TOKEN_STRING = 258,
   TOKEN_INTEGER = 259,
   TOKEN_NAG = 260,
   TOKEN_RESULT = 261
};

typedef struct {
   int type;
   char string[PGN_STRING_SIZE];
} PGNToken;

@interface GameParser : NSObject {
   NSString *gameString;
   char *gameCString;
   int currentCharIndex;
   int charHack;
   BOOL charUnread;
   BOOL tokenUnread;
   int tokenType;
   char tokenString[PGN_STRING_SIZE];
   int tokenLength;
}

-(id)initWithString:(NSString *)string;
-(BOOL)getNextToken:(PGNToken *)token;
-(NSString *)readComment;

@end
