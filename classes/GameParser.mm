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

#import "GameParser.h"


// constants

static const int CHAR_EOF = 256;

// prototypes

static BOOL is_symbol_start(int c);
static BOOL is_symbol_next(int c);

@interface GameParser (PrivateAPI)
-(void)skipBlanks;
-(void)tokenRead;
-(void)tokenUnread;
-(void)charRead;
-(void)charUnread;
@end

@implementation GameParser

-(id)initWithString:(NSString *)string {
   self = [super init];
   gameString = string;
   gameCString = (char *)malloc(strlen([gameString UTF8String]) * sizeof(char) + 1);
   strcpy(gameCString, [gameString UTF8String]);
   currentCharIndex = 0;
   charUnread = NO;
   tokenUnread = NO;
   return self;
}

-(BOOL)getNextToken:(PGNToken *)token {
   [self tokenRead];
   if (tokenType == TOKEN_EOF) return NO;
   else {
      token->type = tokenType;
      strcpy(token->string, tokenString);
      return YES;
   }
}

-(void)tokenRead {
   if (tokenUnread) {
      tokenUnread = NO;
      return;
   }

   [self skipBlanks];
   tokenType = TOKEN_ERROR;
   strcpy(tokenString, "");
   tokenLength = 0;

   // determine token type
   if (NO) {
   } else if (charHack == CHAR_EOF) {
      tokenType = TOKEN_EOF;
   } else if (strchr(".[]()<>{}", charHack) != NULL) {
      // single-character token
      tokenType = charHack;
      sprintf(tokenString, "%c", charHack);
      tokenLength = 1;
   }
   else if (charHack == '*') {
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
            NSException *e =
               [NSException exceptionWithName: @"PGNParseException"
                                       reason: [NSString stringWithFormat:
                                                            @"Symbol %s too long",
                                                         tokenString]
                                     userInfo: nil];
            @throw e;
         }
         if (!isdigit(charHack)) tokenType = TOKEN_SYMBOL;
         tokenString[tokenLength++] = charHack;
         [self charRead];
      } while (charHack != CHAR_EOF && is_symbol_next(charHack));

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
            NSException *e =
               [NSException exceptionWithName: @"PGNParseException"
                                       reason: [NSString stringWithFormat:
                                                            @"Unterminated string: %s",
                                                         tokenString]
                                     userInfo: nil];
            @throw e;
         }
         if (charHack == '"') break;
         if (charHack == '\\') {
            [self charRead];

            if (charHack == CHAR_EOF) {
               NSException *e =
                  [NSException exceptionWithName: @"PGNParseException"
                                          reason: [NSString stringWithFormat:
                                                               @"Unterminated string: %s",
                                                            tokenString]
                                        userInfo: nil];
               @throw e;
            }
            if (charHack != '"' && charHack != '\\') {
               // bad escape, ignore
               if (tokenLength >= PGN_STRING_SIZE-1) {
                  NSException *e =
                     [NSException exceptionWithName: @"PGNParseException"
                                             reason: [NSString stringWithFormat:
                                                              @"String too long: %s",
                                                               tokenString]
                                           userInfo: nil];
                  @throw e;
               }
               tokenString[tokenLength++] = '\\';
            }
         }
         if (tokenLength >= PGN_STRING_SIZE-1) {
            NSException *e =
               [NSException exceptionWithName: @"PGNParseException"
                                       reason: [NSString stringWithFormat:
                                                        @"String too long: %s",
                                                         tokenString]
                                     userInfo: nil];
            @throw e;
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
            NSException *e =
               [NSException exceptionWithName: @"PGNParseException"
                                       reason: [NSString stringWithFormat:
                                                           @"NAG too long: %s",
                                                         tokenString]
                                     userInfo: nil];
            @throw e;
         }
         tokenString[tokenLength++] = charHack;
      }
      [self charUnread];
      if (tokenLength == 0) {
         NSException *e =
            [NSException exceptionWithName: @"PGNParseException"
                                    reason: [NSString stringWithFormat:
                                                         @"Invalid NAG: %s",
                                                      tokenString]
                                  userInfo: nil];
         @throw e;
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
               NSException *e =
                  [NSException exceptionWithName: @"PGNParseException"
                                          reason: [NSString stringWithFormat:
                                                               @"Unterminated comment"]
                                        userInfo: nil];
               @throw e;
            }
         } while (charHack != '\n');
      } else if (charHack == '%' && currentCharIndex >= 2 &&
                 gameCString[currentCharIndex - 2] == '\n') { // Ugly. Fix me!
         // skip comment to EOL
         do {
            [self charRead];
            if (charHack == CHAR_EOF) {
               NSException *e =
                  [NSException exceptionWithName: @"PGNParseException"
                                          reason: [NSString stringWithFormat:
                                                               @"Unterminated comment"]
                                        userInfo: nil];
               @throw e;
            }
         } while (charHack != '\n');
      }
      else { // not a white space
         break;
      }
   }
}

-(NSString *)readComment {
   char *cstring;
   int length, size = 1024, depth = 1;
   char c;
   cstring = (char *)malloc(size * sizeof(char));
   length = 0;
   for (c = gameCString[currentCharIndex++]; c != '\0';
        c = gameCString[currentCharIndex++]) {
      if (c == '{') depth++;
      else if (c == '}') depth--;
      if (depth == 0) break;

      if (c == '\n' || c == '\r') c = ' ';
      cstring[length++] = c;
      if (length >= size - 1) {
         size *= 2;
         cstring = (char *)realloc(cstring, size * sizeof(char));
      }
   }
   cstring[length] = '\0';
   
   NSString *result = [[NSString stringWithUTF8String: cstring]
                       stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
   free(cstring);
   return result;
}

-(void)charRead {
   if (charUnread) {
      charUnread = NO;
      return;
   }
   charHack = gameCString[currentCharIndex++];
   if (charHack == '\0') charHack = CHAR_EOF;
}

-(void)tokenUnread {
   tokenUnread = YES;
}

-(void)charUnread {
   charUnread = YES;
}

-(void)dealloc {
   free(gameCString);
}

static BOOL is_symbol_start(int c) {
   return strchr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",c) != NULL;
}

static BOOL is_symbol_next(int c) {
   return strchr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_+#=:-/",c) != NULL;
}

@end
