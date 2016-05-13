/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class CircleView;

@interface SelectedSquareView : UIView {
   CircleView *circleView;
}

- (void)hide;
- (void)moveToPoint:(CGPoint)point;

@end
