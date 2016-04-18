/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski

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
