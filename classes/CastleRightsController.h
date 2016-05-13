/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class SetupBoardView;

@interface CastleRightsController : UIViewController {
   SetupBoardView *boardView;
   UISwitch *wOOOswitch, *wOOswitch, *bOOOswitch, *bOOswitch;
   NSString *fen;
}

- (id)initWithFen:(NSString *)aFen;
- (void)donePressed;


@end
