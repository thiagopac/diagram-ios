/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <Foundation/Foundation.h>

#include "../Chess/position.h"

using namespace Chess;

@interface ChessMove : NSObject {
   Move move;
   UndoInfo undoInfo;
}

@property (nonatomic, assign) Move move;
@property (nonatomic, assign) UndoInfo undoInfo;

- (id)initWithMove:(Move)m undoInfo:(UndoInfo)ui;

@end
