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

#import "PGN.h"

#import "PGN.h"
#import "PGN.h"

#import <sys/stat.h>


// constants

static const int TAB_SIZE = 8;
static const int CHAR_EOF = 256;

// types

enum token_t {
   TOKEN_ERROR = -1,
   TOKEN_EOF = 256,
   TOKEN_SYMBOL = 257,
   TOKEN_STRING = 258,
   TOKEN_INTEGER = 259,
   TOKEN_NAG = 260,
   TOKEN_RESULT = 261
};

// prototypes

static BOOL is_symbol_start(int c);
static BOOL is_symbol_next(int c);
static void raisePGNException(NSString *exceptionreason);

// private methods:

@interface PGN (PrivateAPI)
-(BOOL)nextMoveIntoCString:(char *)string withSize:(int)size;
-(BOOL)skipMove;
-(void)tokenRead;
-(void)tokenUnread;
-(void)readToken;
-(void)skipBlanks;
-(void)charRead;
-(void)charUnread;
@end

@implementation PGN

-(id)initWithFilename:(NSString *)aFilename {
   self = [super init];

   gameIndicesSize = 1024;
   gameIndices = (int *)malloc(gameIndicesSize * sizeof(int));
   filteredGameIndices = NULL;
   filename = aFilename;
   file = fopen([[PGN_DIRECTORY stringByAppendingPathComponent: aFilename]
                  UTF8String], "r");
   if (file) {
      filename = [PGN_DIRECTORY stringByAppendingPathComponent: aFilename];
   } else {
      file = fopen([aFilename UTF8String], "r");
      assert(file);
      filename = aFilename;
   }

   charHack = CHAR_EOF; // DEBUG
   charColumn = 0;
   charUnread = NO;
   charFirst = YES;

   tokenType = TOKEN_ERROR; // DEBUG
   strcpy(tokenString, "?"); // DEBUG
   tokenLength = -1; // DEBUG
   depth = 0;
   tokenUnread = NO;
   tokenFirst = YES;

   strcpy(result, "?"); // DEBUG
   strcpy(fen, "?"); // DEBUG

   searchString = nil;
   
   return self;
}

-(void)initializeGameIndices {
   numberOfGames = 0;
   gameIndices[0] = 0;
   while ([self nextGame]) {
      while ([self skipMove]);
       numberOfGames++;
      if (numberOfGames >= gameIndicesSize) {
         gameIndicesSize *= 2;
         gameIndices = (int *)realloc(gameIndices, gameIndicesSize * sizeof(int));
      }
      gameIndices[numberOfGames] = (int)ftell(file);
   }
   [self rewind];
   [self filterByPlayerName: searchString];
}

-(void)close {
   fclose(file);
}

-(BOOL)nextGame {
   char name[PGN_STRING_SIZE], value[PGN_STRING_SIZE];

   // init
   strcpy(result, "*");
   strcpy(fen, "");

   // loop
   while (YES) {
      [self tokenRead];
      if (tokenType != '[') break;

      // tag
      [self tokenRead];
      if (tokenType != TOKEN_SYMBOL) {
         // Error
      }
      strcpy(name, tokenString);

      [self tokenRead];
      if (tokenType != TOKEN_STRING) {
         // Error
      }
      strcpy(value, tokenString);

      [self tokenRead];
      if (tokenType != ']') {
         // Error
      }

      // special tag?
      if (NO) {
      } else if (strcmp(name, "White") == 0) {
         strcpy(white, value);
      } else if (strcmp(name, "Black") == 0) {
         strcpy(black, value);
      } else if (strcmp(name, "Site") == 0) {
         strcpy(site, value);
      } else if (strcmp(name, "Event") == 0) {
         strcpy(event, value);
      } else if (strcmp(name, "Round") == 0) {
         strcpy(round, value);
      } else if (strcmp(name, "Date") == 0) {
         strcpy(date, value);
      } else if (strcmp(name, "Result") == 0) {
         strcpy(result, value);
      } else if (strcmp(name, "FEN") == 0) {
         strcpy(fen, value);
      }
   }

   if (tokenType == TOKEN_EOF) return NO;

   [self tokenUnread];

   return YES;
}

-(BOOL)nextMove:(NSString **)string {
   char cstring[256];
   if ([self nextMoveIntoCString: cstring withSize: 256]) {
      *string = [NSString stringWithUTF8String: cstring];
      return YES;
   }
   return NO;
}

-(BOOL)nextMoveIntoCString:(char *)string withSize:(int)size {
   while (YES) {
      [self tokenRead];
      if (NO) {
      } else if (tokenType == '(') {
         // open RAV
         depth++;
      } else if (tokenType == ')') {
         // close RAV
         if (depth == 0) {
            // Error
         }
         depth--;
      } else if (tokenType == TOKEN_RESULT) {
         // game finished
         if (depth > 0) {
            // Error
         }
         return NO;
      } else {
         // skip optional move number
         if (tokenType == TOKEN_INTEGER) {
            do [self tokenRead]; while (tokenType == '.');
         }

         // move must be a symbol
         if (tokenType != TOKEN_SYMBOL) {
            // Error
         }

         // store move for later use
         if (depth == 0) {
            if (tokenLength >= size) {
               // Error
            }
            strcpy(string, tokenString);
         }

         // skip optional NAGs
         do [self tokenRead]; while (tokenType == TOKEN_NAG);
         [self tokenUnread];

         // return move;
         if (depth == 0)
            return YES;
      }
   }
   return NO;
}

-(BOOL)skipMove {
   while (YES) {
      [self tokenRead];
      if (NO) {
      } else if (tokenType == '(') {
         depth++;
      } else if (tokenType == ')') {
         if (depth == 0) {
            // Error
         }
         depth--;
      }
      else if (tokenType == TOKEN_RESULT) {
         if (depth > 0) {
            // Error
         }
         return NO;
      } else {
         if (tokenType == TOKEN_INTEGER) {
            do [self tokenRead]; while (tokenType == '.');
         }
         if (tokenType != TOKEN_SYMBOL) {
            // Error
         }
         do [self tokenRead]; while (tokenType == TOKEN_NAG);
         [self tokenUnread];

         if (depth == 0)
            return YES;
      }
   }
   return NO;
}

-(void)tokenRead {
   // token "stack"
   if (tokenUnread) {
      tokenUnread = NO;
      return;
   }

   // consume the current token
   if (tokenFirst) tokenFirst = NO;

   // read a new token
   [self readToken];
   if (tokenType == TOKEN_ERROR) {
      // Error
   }
}

-(void)tokenUnread {
   tokenUnread = YES;
}

-(void)readToken {
   // skip white-space characters
   [self skipBlanks];

   // init
   tokenType = TOKEN_ERROR;
   strcpy(tokenString, "");
   tokenLength = 0;

   // determine token type
   if (NO) {
   } else if (charHack == CHAR_EOF) {
      tokenType = TOKEN_EOF;
   } else if (strchr(".[]()<>", charHack) != NULL) {
      // single-character token
      tokenType = charHack;
      sprintf(tokenString, "%c", charHack);
      tokenLength = 1;
   } else if (charHack == '*') {
      tokenType = TOKEN_RESULT;
      sprintf(tokenString, "%c", charHack);
      tokenLength = 1;
   } else if (charHack == '!') {
      [self charRead];
      if (NO) {
      } else if (charHack == '!') { // "!!"
         tokenType = TOKEN_NAG;
         strcpy(tokenString, "3");
         tokenLength = 1;
      } else if (charHack == '?') { // "!?"
         tokenType = TOKEN_NAG;
         strcpy(tokenString, "5");
         tokenLength = 1;
      } else { // "!"
         [self charUnread];
         tokenType = TOKEN_NAG;
         strcpy(tokenString, "1");
         tokenLength = 1;
      }
   } else if (charHack == '?') {
      [self charRead];
      if (NO) {
      } else if (charHack == '?') { // "??"
         tokenType = TOKEN_NAG;
         strcpy(tokenString, "4");
         tokenLength = 1;
      } else if (charHack == '!') { // "?!"
         tokenType = TOKEN_NAG;
         strcpy(tokenString, "6");
         tokenLength = 1;
      } else { // "?"
         [self charUnread];
         tokenType = TOKEN_NAG;
         strcpy(tokenString, "2");
         tokenLength = 1;
      }
   } else if (is_symbol_start(charHack)) {
      // symbol, integer, or result
      tokenType = TOKEN_INTEGER;
      tokenLength = 0;
      do {
         if (tokenLength >= PGN_STRING_SIZE - 1) {
            // Errorn
         }
         if (!isdigit(charHack)) tokenType = TOKEN_SYMBOL;
         tokenString[tokenLength++] = charHack;
         [self charRead];
      } while (is_symbol_next(charHack));

      [self charUnread];
      tokenString[tokenLength] = '\0';

      if (strncmp(tokenString, "1-0", 3) == 0 ||
          strncmp(tokenString, "0-1", 3) == 0 ||
          strncmp(tokenString, "1/2-1/2", 7) == 0) {
         tokenType = TOKEN_RESULT;
      }
   } else if (charHack == '"') {
      // string
      tokenType = TOKEN_STRING;
      tokenLength = 0;
      while (YES) {
         [self charRead];
         if (charHack == CHAR_EOF) {
            // Error
         }
         if (charHack == '"') break;
         if (charHack == '\\') {
            [self charRead];
            if (charHack == CHAR_EOF) {
               // Error
            }
            if (charHack != '"' && charHack != '\\') {
               // bad escape, ignore
               if (tokenLength >= PGN_STRING_SIZE-1) {
                  // Error
               }
               tokenString[tokenLength++] = '\\';
            }
         }

         if (tokenLength >= PGN_STRING_SIZE-1) {
            // Error
         }
         tokenString[tokenLength++] = charHack;
      }
      tokenString[tokenLength] = '\0';
   } else if (charHack == '$') {
      // NAG
      tokenType = TOKEN_NAG;
      tokenLength = 0;
      while (YES) {
         [self charRead];
         if (!isdigit(charHack)) break;
         if (tokenLength >= 3) {
            // Error
         }
         tokenString[tokenLength++] = charHack;
      }
      [self charUnread];

      if (tokenLength == 0) {
         // Error
      }
      tokenString[tokenLength] = '\0';
   } else {
      // unknown token
   }
}

-(void)skipBlanks {
   while (YES) {
      [self charRead];
      if (NO) {
      } else if (isspace(charHack)) {
         // skip white space
      } else if (charHack == ';') {
         // skip comment to EOL
         do {
            [self charRead];
            if (charHack == CHAR_EOF) {
               // Error
            }
         } while (charHack != '\n');
      } else if (charHack == '%' && charColumn == 0) {
         // skip comment to EOL
         do {
            [self charRead];
            if (charHack == CHAR_EOF) {
               // Error
            }
         } while (charHack != '\n');
      } else if (charHack == '{') {
         // skip comment to next '}'
         do {
            [self charRead];
            if (charHack == CHAR_EOF) {
               // Error
            }
         } while (charHack != '}');
      } else { // not a white space
         break;
      }
   }
}

static BOOL is_symbol_start(int c) {
   return strchr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",c) != NULL;
}

static BOOL is_symbol_next(int c) {
   return
      c != TOKEN_EOF &&
      strchr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_+#=:-/",c) != NULL;
}

static void raisePGNException(NSString *exceptionreason) {
   NSException *e = [NSException exceptionWithName: @"PGNParseException"
                                            reason: exceptionreason
                                          userInfo: nil];
   NSLog(@"throwing exception %@", e);
   @throw e;
   //  [e raise];
}

-(void)charRead {
   // char "stack"
   if (charUnread) {
      charUnread = NO;
      return;
   }

   // consume the current character
   if (charFirst) {
      charFirst = NO;
   } else {
      // update counters
      if (NO) {
      } else if (charHack == '\n') {
         charColumn = 0;
      } else if (charHack == '\t') {
         charColumn += TAB_SIZE - (charColumn % TAB_SIZE);
      } else {
         charColumn++;
      }
   }

   // read a new character
   charHack = fgetc(file);
   if (charHack == EOF) {
      charHack = TOKEN_EOF;
   }
}

-(void)charUnread {
   charUnread = YES;
}

-(void)rewind {
   rewind(file);
}

-(NSString *)white {
   return [NSString stringWithUTF8String: white];
}

-(NSString *)black {
   return [NSString stringWithUTF8String: black];
}

-(NSString *)event {
   return [NSString stringWithUTF8String: event];
}

-(NSString *)date {
   return [NSString stringWithUTF8String: date];
}

-(NSString *)site {
   return [NSString stringWithUTF8String: site];
}

-(NSString *)round {
   return [NSString stringWithUTF8String: round];
}

-(NSString *)result {
   return [NSString stringWithUTF8String: result];
}

- (void)goToGameNumber:(int)number useFilter:(BOOL)useFilter {
   int numOfGames = useFilter? numberOfFilteredGames : numberOfGames;
   int *indices = useFilter? filteredGameIndices : gameIndices;
   if (number < 0 || number >= numOfGames)
      [[NSException exceptionWithName: @"PGNGameOutOfBounds"
                               reason: @"Game number out of bounds for PGN file"
                             userInfo: nil]
       raise];
   charUnread = NO;
   tokenUnread = NO;
   fseek(file, indices[number], SEEK_SET);
   [self nextGame];
}

-(void)goToGameNumber:(int)number {
   [self goToGameNumber: number useFilter: YES];
   /*
   if (number < 0 || number >= numberOfFilteredGames)
      [[NSException exceptionWithName: @"PGNGameOutOfBounds"
                               reason: @"Game number out of bounds for PGN file"
                             userInfo: nil]
         raise];
   charUnread = NO;
   tokenUnread = NO;
   fseek(file, gameIndices[number], SEEK_SET);
   [self nextGame];
    */
}

- (NSString *)pgnStringForGameNumber:(int)number useFilter:(BOOL)useFilter {
   int numOfGames = useFilter? numberOfFilteredGames : numberOfGames;
   int *indices = useFilter? filteredGameIndices : gameIndices;
   int start, stop, current, ch;
   
   NSMutableString *mstr = [[NSMutableString alloc] initWithString: @""];
   NSString *str;
   if (number < 0 || number >= numOfGames)
      [[NSException exceptionWithName: @"PGNGameOutOfBounds"
                               reason: @"Game number out of bounds for PGN file"
                             userInfo: nil]
       raise];
   current = start = indices[number];
   if (!useFilter)
      stop = indices[number+1];
   else {
      for (int i = 1; i <= numberOfGames; i++)
         if (gameIndices[i] > indices[number]) {
            stop = gameIndices[i];
            break;
         }
   }
   fseek(file, start, SEEK_SET);
   while (current < stop) {
      ch = fgetc(file);
      [mstr appendFormat: @"%c", ch];
      current++;
   }
   str = [NSString stringWithString: mstr];
   return str;
   
}

-(NSString *)pgnStringForGameNumber:(int)number {
   return [self pgnStringForGameNumber: number useFilter: YES];
   /*
   int start, stop, current, ch;
   NSMutableString *mstr = [[NSMutableString alloc] initWithString: @""];
   NSString *str;
   if (number < 0 || number >= numberOfGames)
      [[NSException exceptionWithName: @"PGNGameOutOfBounds"
                               reason: @"Game number out of bounds for PGN file"
                             userInfo: nil]
         raise];
   current = start = gameIndices[number];
   stop = gameIndices[number+1];
   fseek(file, start, SEEK_SET);
   while (current < stop) {
      ch = fgetc(file);
      [mstr appendFormat: @"%c", ch];
      current++;
   }
   str = [NSString stringWithString: mstr];
   [mstr release];
   return str;
    */
}

-(NSString *)moveList {
   char cstr[256];
   NSMutableString *mstring = [[NSMutableString alloc] initWithString: @""];
   NSString *string;

   while ([self nextMoveIntoCString: cstr withSize: 256]) {
      [mstring appendString: [NSString stringWithUTF8String: cstr]];
   }
   string = [NSString stringWithString: mstring];
   return string;
}

- (int)numberOfGames {
   return numberOfGames;
}

- (int)numberOfFilteredGames {
   return numberOfFilteredGames;
}

- (void)deleteGameNumber:(int)number {
   assert(number >= 0 && number < numberOfGames);
   
   rewind(file);
   NSString *tmpFilename = [NSString stringWithFormat: @"%@.tmp", filename];
   FILE *tmpFile = fopen([tmpFilename UTF8String], "w");
   
   int initialChunkEnd, finalChunkStart;
   initialChunkEnd = filteredGameIndices[number];
   if (filteredGameIndices == gameIndices)
      finalChunkStart = gameIndices[number + 1];
   else {
      // A binary search would be better, but I'm lazy, and this is
      // probably more than fast enough.
      for (int i = 0; i < numberOfGames; i++)
         if (gameIndices[i] > initialChunkEnd) {
            finalChunkStart = gameIndices[i];
            break;
         }
   }
   
   for (int i = 0; i < initialChunkEnd; i++)
      fputc(fgetc(file), tmpFile);
   fseek(file, finalChunkStart, SEEK_SET);
   for (int i = finalChunkStart; i <= gameIndices[numberOfGames]; i++)
      fputc(fgetc(file), tmpFile);
   /*
   for (int i = 0; i < gameIndices[number]; i++)
      fputc(fgetc(file), tmpFile);
   fseek(file, gameIndices[number + 1], SEEK_SET);
   for (int i = gameIndices[number + 1]; i <= gameIndices[numberOfGames]; i++)
      fputc(fgetc(file), tmpFile);
    */
   fclose(file);
   fclose(tmpFile);
   rename([tmpFilename UTF8String], [filename UTF8String]);
   file = fopen([filename UTF8String], "r");
   
   [self initializeGameIndices];
}

- (NSString *)filename {
   return filename;
}

- (void)filterByPlayerName:(NSString *)name {
   if (filteredGameIndices != NULL && filteredGameIndices != gameIndices)
      free(filteredGameIndices);
   if (name == nil) {
      numberOfFilteredGames = numberOfGames;
      filteredGameIndices = gameIndices;
   } else {
      filteredGameIndices = (int *)malloc(numberOfGames * sizeof(int));
      int numOfFilteredGames = 0;
      for (int i = 0; i < numberOfGames; i++) {
         [self goToGameNumber: i useFilter: NO];
         if ([[self white] rangeOfString: name options: NSCaseInsensitiveSearch].location != NSNotFound)
            filteredGameIndices[numOfFilteredGames++] = gameIndices[i];
         else if ([[self black] rangeOfString: name options: NSCaseInsensitiveSearch].location != NSNotFound)
            filteredGameIndices[numOfFilteredGames++] = gameIndices[i];
      }
      NSLog(@"found %d games", numOfFilteredGames);
      numberOfFilteredGames = numOfFilteredGames;
   }
}


- (void)clearFilter {
   [self filterByPlayerName: nil];
}


- (BOOL)filterIsActive {
   return numberOfGames != numberOfFilteredGames;
}


- (BOOL)isEmpty {
   return numberOfGames == 0;
}

-(void)dealloc {
   [self close];
   if ([self isEmpty]) {
      if (!remove([filename UTF8String]))
         NSLog(@"removed file %@", filename);
      else
         NSLog(@"failed to remove file %@", filename);
   }
      
   if (filteredGameIndices != NULL && filteredGameIndices != gameIndices)
      free(filteredGameIndices);
   free(gameIndices);
}

@end
