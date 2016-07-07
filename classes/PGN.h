/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "TargetConditionals.h"

#define PGN_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"]
#define ENGINE_NAME @"Diagram"

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
