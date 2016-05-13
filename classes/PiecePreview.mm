/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import "Game.h"
#import "Options.h"
#import "PiecePreview.h"

@implementation PiecePreview

- (id)initWithFrame:(CGRect)frame
        colorScheme:(NSString *)colorScheme
           pieceSet:(NSString *)pieceSet {
   if (self = [super initWithFrame: frame]) {
      darkSquareColor = [[Options sharedOptions] darkSquareColorForColorScheme: colorScheme];
      lightSquareColor = [[Options sharedOptions] lightSquareColorForColorScheme: colorScheme];
      darkSquareImage = [[Options sharedOptions] darkSquareImageForColorScheme: colorScheme
                                                                          large: NO];
      lightSquareImage = [[Options sharedOptions] lightSquareImageForColorScheme: colorScheme
                                                                            large: NO];
      static NSString *pieceImageNames[16] = {
         nil, @"WPawn", @"WKnight", @"WBishop", @"WRook",
         @"WQueen", @"WKing", nil, nil, @"BPawn", @"BKnight",
         @"BBishop", @"BRook", @"BQueen", @"BKing", nil
      };
      for (Piece p = WP; p <= BK; p++) {
         if (piece_is_ok(p))
            pieceImages[p] =
            [UIImage imageNamed: [NSString stringWithFormat: @"%@%@.png",
                                   pieceSet,
                                   pieceImageNames[p]]];
         else
            pieceImages[p] = nil;
      }
      
      
   }
   return self;
}


- (void)drawRect:(CGRect)rect {
   int i, j;
   UIImageView *v;
   CGRect r;
   float sz = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40.0f : [[UIScreen mainScreen] applicationFrame].size.width / 8.0f;
   
   for (i = 0; i < 6; i++) {
      for (j = 0; j < 2; j++) {
         r = CGRectMake(i * sz, j * sz, sz, sz);
         if (darkSquareImage && lightSquareImage)
            [(((i + j) & 1)? darkSquareImage : lightSquareImage)
             drawInRect: CGRectMake(i * sz, j * sz, sz, sz)];
         else {
            [(((i + j) & 1) ? darkSquareColor : lightSquareColor) set];
            UIRectFill(r);
         }
         v = [[UIImageView alloc] initWithFrame: r];
         [v setImage: pieceImages[(i + 1) + (1 - j) * 8]];
         [self addSubview: v];
      }
   }
   self.layer.borderColor =
   [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha: 1.0].CGColor;
   self.layer.borderWidth = 1.0;
}


- (void)dealloc {
   for (Piece p = WP; p <= BK; p++) ;
}

@end
