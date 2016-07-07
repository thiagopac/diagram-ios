/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>
#import "Game.h"
#import "SetupBoardView.h"

@class GameController;

@interface SideToMoveController : UIViewController {
   SetupBoardView *boardView;
    UISegmentedControl *segmentedControl;
    UIButton *btnWhite;
    UIButton *btnBlack;
    NSString *fen;
    UILabel *warningLabel;
    GameController *gameController;
}

@property (nonatomic, readonly) Game *game;
@property (nonatomic, readonly) GameController *gameController;

- (id)initWithFen:(NSString *)aFen;

@end
