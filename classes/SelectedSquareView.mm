/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import "Options.h"
#import "SelectedSquareView.h"

@interface CircleView : UIView { }
@end

@implementation CircleView
- (void)drawRect:(CGRect)rect {
   CGContextRef context = UIGraphicsGetCurrentContext();
   [[Options sharedOptions].selectedSquareColor set];
   CGContextFillEllipseInRect(context, rect);
}
@end



@implementation SelectedSquareView

/*
- (id)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame:frame]) {
      circleView = nil;
   }
   return self;
}
 */


- (void)hide {
   if (circleView != nil) {
      [circleView removeFromSuperview];
      circleView = nil;
   }
   [self setNeedsDisplay];
   [super setNeedsDisplay];
}


- (void)moveToPoint:(CGPoint)point {
   CGRect r = [self frame];
   r.origin = point;
   [self setFrame: r];
   CGRect r0 = CGRectMake(0.0f, 0.0f, r.size.width, r.size.height);
   CGRect r1 = CGRectInset(r0, 0.25f * r0.size.width, 0.25f * r0.size.height);
   if (circleView == nil) {
      circleView = [[CircleView alloc] initWithFrame: r0 ];
      [self addSubview: circleView];
   } else {
      circleView.frame = r0;
   }
   circleView.alpha = 0.2f;
   circleView.opaque = NO;
   [circleView setNeedsDisplay];
   [UIView animateWithDuration:0.65f
                         delay:0
        usingSpringWithDamping:0.6f
         initialSpringVelocity:0.0f
                       options:0
                    animations:^{
                       circleView.frame = r1;
                       circleView.alpha = 1.0f;
                    }
                    completion:nil];
   [self setNeedsDisplay];
}




@end
