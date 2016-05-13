/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>


@interface CoordinatesView : UIView {
   BOOL isFlipped;
   float sqSize;
   UILabel *fileLabels[8], *rankLabels[8];
}

- (id)initWithFrame:(CGRect)frame flipped:(BOOL)flipped;

@property (nonatomic, readwrite) BOOL isFlipped;

@end
