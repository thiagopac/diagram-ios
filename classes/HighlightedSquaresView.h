/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#include "../Chess/square.h"

using namespace Chess;

@interface HighlightedSquaresView : UIView {
   Square squares[32];
   Square selectedSquare;
   float sqSize;
   BOOL shouldIgnoreShowLegalMovesOption;
}

@property (nonatomic, assign) Square selectedSquare;

- (id)initWithFrame:(CGRect)frame squares:(Square *)sqs
ignoreShowLegalMovesOption:(BOOL)ignoreShowLegalMovesOption;
- (id)initWithFrame:(CGRect)frame squares:(Square *)sqs;

@end
