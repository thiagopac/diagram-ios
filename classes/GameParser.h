/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
