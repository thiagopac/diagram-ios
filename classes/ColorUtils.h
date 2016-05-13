/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKIt/UIKit.h>


@interface UIColor (ColorUtils)

-(UIColor *)complementaryColor;
-(UIColor *)interpolateTowardsColor:(UIColor *)otherColor atPoint:(float)point;
+(UIColor *)systemTintColor;

@end