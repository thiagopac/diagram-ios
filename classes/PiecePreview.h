/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */


#import <UIKit/UIKit.h>

@interface PiecePreview : UIView {
   UIColor *darkSquareColor, *lightSquareColor;
   UIImage *darkSquareImage, *lightSquareImage;
   UIImage *pieceImages[16];
}

- (id)initWithFrame:(CGRect)frame
        colorScheme:(NSString *)colorScheme
           pieceSet:(NSString *)pieceSet;

@end

