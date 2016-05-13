/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "RootView.h"


@implementation RootView


- (id)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame:frame]) {
      // Initialization code
   }
   return self;
}


- (void)drawRect:(CGRect)rect {
   // Drawing code
}


- (void)flipSubviewsLeft {
   CGContextRef context = UIGraphicsGetCurrentContext();
   [UIView beginAnimations: nil context: context];
   [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft /*UIViewAnimationTransitionFlipFromLeft*/
                          forView: self cache: YES];
   [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDuration: 0.5];
   [self exchangeSubviewAtIndex: 0 withSubviewAtIndex: 1];
   [UIView commitAnimations];
}


- (void)flipSubviewsRight {
   CGContextRef context = UIGraphicsGetCurrentContext();
   [UIView beginAnimations: nil context: context];
   [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight /*UIViewAnimationTransitionFlipFromRight*/
                          forView: self cache: YES];
   [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDuration: 0.5];
   [self exchangeSubviewAtIndex: 0 withSubviewAtIndex: 1];
   [UIView commitAnimations];
}



@end
