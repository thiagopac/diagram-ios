/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class BoardPreview;
@class Game;

@interface MoveListCell : UITableViewCell {
   UILabel *whiteMoveText, *blackMoveText;
   BoardPreview *boardPreview;
}

- (void)showBoardForGame:(Game *)g atPly:(int)ply;
- (void)removeBoardForGame:(Game *)g atPly:(int)ply;
- (BOOL)hasBoardPreview;

@property (nonatomic, strong) UILabel *whiteMoveText;
@property (nonatomic, strong) UILabel *blackMoveText;

@end
