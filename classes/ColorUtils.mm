/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski.

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