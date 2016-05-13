/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "ColorUtils.h"


@implementation UIColor (ColorUtils)

-(UIColor *)complementaryColor {
   CGFloat h, s, b, a;
   [self getHue:&h saturation:&s brightness:&b alpha:&a];
   return [UIColor colorWithHue:h > 0.5f ? h - 0.5f : h + 0.5f
                     saturation:s
                     brightness:b
                          alpha:a];
}


-(UIColor *)interpolateTowardsColor:(UIColor *)otherColor
                            atPoint:(float)point {
   CGFloat r1, g1, b1, r2, g2, b2, a1, a2;
   [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
   [otherColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
   return [UIColor colorWithRed: r1 + point * (r2 - r1)
                          green: g1 + point * (g2 - g1)
                           blue: b1 + point * (b2 - b1)
                          alpha: a1 + point * (a2 - a1)];
}


+(UIColor *)systemTintColor {
   return [[UIView alloc] init].tintColor;
}


@end