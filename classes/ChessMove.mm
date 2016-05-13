/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "ChessMove.h"

@implementation ChessMove

@synthesize move, undoInfo;

- (id)initWithMove:(Move)m undoInfo:(UndoInfo)ui {
   if (self = [super init]) {
      move = m;
      undoInfo = ui;
   }
   return self;
}

@end
