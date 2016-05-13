/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#include "../Chess/square.h"

using namespace Chess;

@interface ArrowView : UIView {
   Square square1, square2;
   float sqSize;
}

- (id)initWithFrame:(CGRect)frame fromSq:(Square)fSq toSq:(Square)tSq;

@end