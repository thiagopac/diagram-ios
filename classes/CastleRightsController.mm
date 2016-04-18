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
#import "CastleRightsController.h"
#import "EpSquareController.h"
#import "SetupBoardView.h"
#import "SetupViewController.h"

@implementation CastleRightsController

- (id)initWithFen:(NSString *)aFen {
   if (self = [super init]) {
      fen = aFen;
      [self setPreferredContentSize: CGSizeMake(320, 430)];
   }
   return self;
}


- (void)loadView {
   [super loadView];

   BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   BOOL isRunningiOS7 = [UIDevice currentDevice].systemVersion.floatValue < 8.0f;

   UIView *contentView;
   CGRect r = [[UIScreen mainScreen] applicationFrame];
   [self setTitle: @"Castle rights"];
   contentView = [[UIView alloc] initWithFrame: r];
   [self setView: contentView];
   [contentView setBackgroundColor: [UIColor colorWithRed: 0.934 green: 0.934 blue: 0.953 alpha: 1.0]];

   [[self navigationItem]
      setRightBarButtonItem: [[UIBarButtonItem alloc]
                                 initWithTitle: @"Done"
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(donePressed)]];

   float sqSize = isIpad ? 40.0f : [UIScreen mainScreen].applicationFrame.size.width / 8.0f;
   CGRect frame;
   if (isIpad && isRunningiOS7) {
      frame = CGRectMake(0.0f, 48.0f, 8 * sqSize, 8 * sqSize);
   } else {
      frame = CGRectMake(0.0f, 110.0f, 8 * sqSize, 8 * sqSize);
   }
   boardView = [[SetupBoardView alloc]
         initWithController: self
                      frame: frame
                        fen: fen
                      phase: PHASE_EDIT_CASTLES];
   [contentView addSubview: boardView];

   UISwitch *s;
   const char *c = [[boardView maybeCastleString] UTF8String];

   float dy = isIpad && isRunningiOS7 ? -64 : 0;
   float sw;
   
   s = [[UISwitch alloc] initWithFrame: CGRectMake(0.0f,0.0f,0.0f,0.0f)];
   r = [s frame];
   sw = r.size.width;
   r.origin = CGPointMake(2 * sqSize - 0.5f * sw, 5.0f + 64.0f + dy);
   [s setFrame: r];
   if (strchr(c, 'q'))
      [s setOn: YES];
   else {
      [s setOn: NO];
      [s setEnabled: NO];
   }
   [contentView addSubview: s];
   bOOOswitch = s;

   s = [[UISwitch alloc] initWithFrame: CGRectMake(0.0f,0.0f,0.0f,0.0f)];
   r = [s frame];
   r.origin = CGPointMake(2 * sqSize - 0.5f * sw, 8 * sqSize + 120.0f + dy);
   [s setFrame: r];
   if (strchr(c, 'Q'))
      [s setOn: YES];
   else {
      [s setOn: NO];
      [s setEnabled: NO];
   }
   [contentView addSubview: s];
   wOOOswitch = s;

   s = [[UISwitch alloc] initWithFrame: CGRectMake(0.0f,0.0f,0.0f,0.0f)];
   r = [s frame];
   r.origin = CGPointMake(6 * sqSize - 0.5f * sw, 5.0f+64.0f + dy);
   [s setFrame: r];
   if (strchr(c, 'k'))
      [s setOn: YES];
   else {
      [s setOn: NO];
      [s setEnabled: NO];
   }
   [contentView addSubview: s];
   bOOswitch = s;

   s = [[UISwitch alloc] initWithFrame: CGRectMake(0.0f,0.0f,0.0f,0.0f)];
   r = [s frame];
   r.origin = CGPointMake(6 * sqSize - 0.5f * sw, 8 * sqSize + 120.0f + dy);
   [s setFrame: r];
   if (strchr(c, 'K'))
      [s setOn: YES];
   else {
      [s setOn: NO];
      [s setEnabled: NO];
   }
   [contentView addSubview: s];
   wOOswitch = s;
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)donePressed {
   NSArray *substrs =
      [fen componentsSeparatedByCharactersInSet:
              [NSCharacterSet whitespaceCharacterSet]];
   char cstr[8];
   int i = 0;
   if ([wOOswitch isOn]||[wOOOswitch isOn]||[bOOswitch isOn]||[bOOOswitch isOn]){
      if ([wOOswitch isOn]) cstr[i++] = 'K';
      if ([wOOOswitch isOn]) cstr[i++] = 'Q';
      if ([bOOswitch isOn]) cstr[i++] = 'k';
      if ([bOOOswitch isOn]) cstr[i++] = 'q';
   }
   else cstr[i++] = '-';
   cstr[i] = '\0';

   Square epSqs[8];
   if ([boardView epCandidateSquares: epSqs]) {
      EpSquareController *epc =
         [[EpSquareController alloc]
            initWithFen: [NSString stringWithFormat: @"%@ %@ %s -",
                             [substrs objectAtIndex: 0],
                             [substrs objectAtIndex: 1],
                                   cstr]];
      [[self navigationController] pushViewController: epc animated: YES];
   }
   else {
      BoardViewController *bvc =
         [(SetupViewController *)
             [[[self navigationController] viewControllers] objectAtIndex: 0]
            boardViewController];

      [bvc editPositionDonePressed:
              [NSString stringWithFormat: @"%@ %@ %s -",
                  [substrs objectAtIndex: 0], [substrs objectAtIndex: 1],
                        cstr]];
   }
}




@end
