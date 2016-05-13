/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "BoardPreview.h"
#import "Game.h"
#import "MoveListCell.h"


@implementation MoveListCell

@synthesize whiteMoveText, blackMoveText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
   self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
   if (self) {
      float width = [[self contentView] bounds].size.width;
      float height = [[self contentView] bounds].size.height;
      whiteMoveText =
         [[UILabel alloc] initWithFrame: CGRectMake(0.0, 0.0, 0.5 * width, height)];
      blackMoveText =
         [[UILabel alloc] initWithFrame: CGRectMake(0.5 * width, 0.0, 0.5 * width, height)];
      [whiteMoveText setFont: [UIFont boldSystemFontOfSize: 21.0]];
      [blackMoveText setFont: [UIFont boldSystemFontOfSize: 21.0]];
      [[self contentView] addSubview: whiteMoveText];
      [[self contentView] addSubview: blackMoveText];
      boardPreview = nil;
      [self setSelectionStyle: UITableViewCellSelectionStyleNone];
   }
   return self;
}

- (void)layoutSubviews {
   [super layoutSubviews];
   float width = [[self contentView] bounds].size.width;
   float height = [[self contentView] bounds].size.height;
   whiteMoveText.frame = CGRectMake(0.0, 0.0, 0.5 * width, height);
   blackMoveText.frame = CGRectMake(0.5 * width, 0.0, 0.5 * width, height);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   [super setSelected: selected animated: animated];
}


- (void)showBoardForGame:(Game *)g atPly:(int)ply {
   CGRect frame;
   float width = [[self contentView] bounds].size.width;
   int btm = (ply + (int)([g startPosition]->side_to_move())) % 2;
   if (btm)
      frame = CGRectMake(4.0, 4.0, 0.5*width-8, 0.5*width-8);
   else
      frame = CGRectMake(0.5*width+4, 4.0, 0.5*width - 8, 0.5*width - 8);
   boardPreview = [[BoardPreview alloc] initWithFrame: frame
                                                 game: g
                                                  ply: ply];
   [self addSubview: boardPreview];
   [self setNeedsDisplay];
}

- (void)removeBoardForGame:(Game*)game atPly:(int)ply {
   [boardPreview removeFromSuperview];
   boardPreview = nil;
   [self setNeedsDisplay];
}

- (BOOL)hasBoardPreview {
   return boardPreview != nil;
}



@end
