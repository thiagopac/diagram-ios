/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "CoordinatesView.h"


@implementation CoordinatesView

@dynamic isFlipped;


- (id)initWithFrame:(CGRect)frame flipped:(BOOL)flipped {
   if (self = [super initWithFrame: frame]) {
      sqSize = frame.size.width / 8;
      [self setUserInteractionEnabled: NO];
      for (int i = 0; i < 8; i++) {
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fileLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake((i+1)*sqSize - 11.0,
                                                          8*sqSize - 15.0,
                                                          13.0, 15.0)];
            [fileLabels[i] setFont: [UIFont systemFontOfSize: 14.0f]];
            rankLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake(2.0,
                                                          i*sqSize + 2.0,
                                                          13.0, 15.0)];
            [rankLabels[i] setFont: [UIFont systemFontOfSize: 14.0f]];
         }
         else {
            fileLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake((i+1)*sqSize - 7.0,
                                                          8*sqSize - 12.0,
                                                          10.0, 12.0)];
            [fileLabels[i] setFont: [UIFont systemFontOfSize: 11.0f]];
            rankLabels[i] =
               [[UILabel alloc] initWithFrame: CGRectMake(2.0,
                                                          i*sqSize + 2.0,
                                                          10.0, 12.0)];
            [rankLabels[i] setFont: [UIFont systemFontOfSize: 11.0f]];
         }
         [fileLabels[i] setTextColor: [UIColor blackColor]];
         [fileLabels[i] setBackgroundColor: [UIColor clearColor]];
         [self addSubview: fileLabels[i]];

         [rankLabels[i] setTextColor: [UIColor blackColor]];
         [rankLabels[i] setBackgroundColor: [UIColor clearColor]];
         [self addSubview: rankLabels[i]];

         [self setIsFlipped: flipped];
      }
   }
   return self;
}

- (void)dealloc {
   NSLog(@"CoordinatesView dealloc");
}


- (BOOL)isFlipped {
   return isFlipped;
}

- (void)setIsFlipped:(BOOL)flip {
   isFlipped = flip;
   for (int i = 0; i < 8; i++) {
      [fileLabels[i]
          setText: [NSString stringWithFormat: @"%c",
                         (char)((flip? (7-i) : i) + 'a')]];
      [rankLabels[i]
          setText: [NSString stringWithFormat: @"%c",
                             (char)((flip? i : (7-i)) + '1')]];
   }
}


@end
