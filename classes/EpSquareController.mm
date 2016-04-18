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

#import "BoardViewController.h"
#import "EpSquareController.h"
#import "SetupBoardView.h"
#import "SetupViewController.h"


@implementation EpSquareController


- (id)initWithFen:(NSString *)aFen {
   if (self = [super init]) {
      fen = aFen;
      //[self setContentSizeForViewInPopover: CGSizeMake(320.0f, 418.0f)];
      [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
   }
   return self;
}


- (void)loadView {
   BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   BOOL isRunningiOS7 = [UIDevice currentDevice].systemVersion.floatValue < 8.0f;

   [super loadView];
   UIView *contentView;
   CGRect r = [[UIScreen mainScreen] applicationFrame];
   [self setTitle: @"E.p. square"];
   contentView = [[UIView alloc] initWithFrame: r];
   [self setView: contentView];
   [contentView setBackgroundColor: [UIColor colorWithRed: 0.934 green:0.934 blue: 0.953 alpha: 1.0]];

   [[self navigationItem]
      setRightBarButtonItem: [[UIBarButtonItem alloc]
                                 initWithTitle: @"Done"
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(donePressed)]];
   float sqSize = isIpad ? 40.0f : [UIScreen mainScreen].applicationFrame.size.width / 8.0f;
   CGRect frame;
   if (isIpad && isRunningiOS7) {
      frame = CGRectMake(0.0f, 6.0f, 8 * sqSize, 8 * sqSize);
   } else if (isIpad) {
      frame = CGRectMake(0.0f, 40.0f, 8 * sqSize, 8 * sqSize);
   } else {
      frame = CGRectMake(0.0f, 64.0f, 8 * sqSize, 8 * sqSize);
   }
   boardView = [[SetupBoardView alloc]
         initWithController: self
                      frame: frame
                        fen: fen
                      phase: PHASE_EDIT_EP];
   [contentView addSubview: boardView];

   float dy = isIpad ? 40.0f : 64.0f;
   if (isIpad && isRunningiOS7) dy -= 34.0f;
   UITextView *textView =
      [[UITextView alloc] initWithFrame:
            CGRectMake(0.0f, 8*sqSize+dy, 8*sqSize, 80.0f)];
   [textView setFont: [UIFont systemFontOfSize: 13.0]];
   [textView setText: @"Select a square for en passant captures from the squares highlighted above, and press \"Done\" when finished. If no en passant capture is possible, just press \"Done\" without selecting a square."];
   [textView setEditable: NO];
   [contentView addSubview: textView];
}


- (void)donePressed {
   BoardViewController *bvc =
      [(SetupViewController *) [[self navigationController] viewControllers][0]
            boardViewController];

   [bvc editPositionDonePressed: [boardView fen]];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

@end
