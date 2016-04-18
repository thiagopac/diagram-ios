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
#import "TargetConditionals.h"

#define PGN_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"]
#define ENGINE_NAME @"Stockfish"

#define PGN_STRING_SIZE 256

@interface PGN : NSObject {
   NSString *filename;
   FILE *file;
   int fileSize;
   int charHack;
   int charColumn;
   BOOL charUnread;
   BOOL charFirst;
   int tokenType;
   char tokenString[PGN_STRING_SIZE];
   int tokenLength;
   BOOL tokenUnread;
   BOOL tokenFirst;
   int depth;
   int numberOfGames;
   int gameIndicesSize;
   int *gameIndices;
   char white[PGN_STRING_SIZE];
   char black[PGN_STRING_SIZE];
   char site[PGN_STRING_SIZE];
   char event[PGN_STRING_SIZE];
   char date[PGN_STRING_SIZE];
   char round[PGN_STRING_SIZE];
   char result[PGN_STRING_SIZE];
   char fen[PGN_STRING_SIZE];
   
   NSString *searchString;
   int numberOfFilteredGames;
   int *filteredGameIndices;
}

- (id)initWithFilename:(NSString *)aFilename;
- (void)initializeGameIndices;
- (void)close;
- (BOOL)nextGame;
- (BOOL)nextMove:(NSString **)string;
- (void)rewind;
- (void)goToGameNumber:(int)number useFilter:(BOOL)useFilter;
- (void)goToGameNumber:(int)number;
- (NSString *)pgnStringForGameNumber:(int)number useFilter:(BOOL)useFilter;
- (NSString *)pgnStringForGameNumber:(int)number;
- (NSString *)moveList;
- (int)numberOfGames;
- (int)numberOfFilteredGames;
- (NSString *)white;
- (NSString *)black;
- (NSString *)event;
- (NSString *)date;
- (NSString *)site;
- (NSString *)round;
- (NSString *)result;
- (void)deleteGameNumber:(int)number;
- (NSString *)filename;
- (void)filterByPlayerName:(NSString *)name;
- (void)clearFilter;
- (BOOL)filterIsActive;
- (BOOL)isEmpty;

@end
