/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
