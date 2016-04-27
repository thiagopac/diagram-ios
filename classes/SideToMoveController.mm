/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski

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
#import "SideToMoveController.h"
#import "ScanViewController.h"
#import "Options.h"
#import "GameController.h"

@implementation SideToMoveController

@synthesize gameController;

- (id)initWithFen:(NSString *)aFen {
   if (self = [super init]) {
      fen = aFen;
      [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
   }
   return self;
}

- (void)loadView {
   UIView *contentView;
   CGRect r = [[UIScreen mainScreen] applicationFrame];
    
    
   [self setTitle: @"My side"];
   contentView = [[UIView alloc] initWithFrame: r];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1.0];
   self.navigationController.navigationBar.topItem.title = @"•";
    
   [self setView: contentView];
   [contentView setBackgroundColor: [UIColor colorWithRed: 0.934 green: 0.934 blue: 0.953 alpha: 1.0]];

//   [self setTitle: @"Side to move"];
//   [[self navigationItem]
//      setRightBarButtonItem: [[UIBarButtonItem alloc]
//                                 initWithTitle: @"Done"
//                                         style: UIBarButtonItemStylePlain
//                                        target: self
//                                        action: @selector(donePressed)]];
    
    
    warningLabel = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, /*20.0f*/385.0f, r.size.width, 18.0f)];
    [warningLabel setFont: [UIFont systemFontOfSize: 14.0]];
    [warningLabel setTextColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0]];
    [warningLabel setTextAlignment:NSTextAlignmentCenter];
    [warningLabel setText:@"Leave empty to play with both sides"];
    [contentView addSubview: warningLabel];

   BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   BOOL isRunningiOS7 = [UIDevice currentDevice].systemVersion.floatValue < 8.0f;
   float sqSize = isIpad ? 40.0f : [UIScreen mainScreen].applicationFrame.size.width / 8.0f;
   CGRect frame;

   if (!isIpad) {
      frame = CGRectMake(0.0f, 64.0f, 8 * sqSize, 8 * sqSize);
   } else if (isRunningiOS7) {
      frame = CGRectMake(0.0f, 0.0f, 8 * sqSize, 8 * sqSize);
   } else {
      frame = CGRectMake(0.0f, 40.0f, 8 * sqSize, 8 * sqSize);
   }
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
    [nextButton setBackgroundColor:[UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0]];
    nextButton.titleLabel.font = [UIFont systemFontOfSize: 20];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    nextButton.frame = CGRectMake(0.0f, r.size.height-25, r.size.width, 45.0f);
    
    [contentView addSubview:nextButton];

    
   boardView = [[SetupBoardView alloc]
         initWithController: self
                      frame: frame
                        fen: fen
                      phase: PHASE_EDIT_STM];
   [contentView addSubview: boardView];

   // UISegmentedControl for picking side to move
   if (!isIpad) {
//      frame = CGRectMake(20.0f, 8 * sqSize + 89.0f, 8 * sqSize - 30.0f, 50.0f);
       frame = CGRectMake(10.0f, 8 * sqSize + 100.0f, 300.0f, 70.0f);
   }  else if (isRunningiOS7) {
      frame = CGRectMake(10.0f, 340.0f, 300.0f, 30.0f);
   } else {
      frame = CGRectMake(20.0f, 380.0f, 280.0f, 10.0f);
   }
    
   NSArray *buttonNames = @[@"♔", @"♚"];
    
   segmentedControl = [[UISegmentedControl alloc] initWithItems: buttonNames];
   segmentedControl.tintColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0];
   segmentedControl.frame = frame;
    
   [segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"STHeitiSC-Medium" size:50.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    segmentedControl.layer.cornerRadius = 15.0;
    segmentedControl.layer.borderColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1.0].CGColor;
    segmentedControl.layer.borderWidth = 1.0f;
    segmentedControl.layer.masksToBounds = YES;
    
    
//   if ([boardView whiteIsInCheck]) {
//      [segmentedControl setSelectedSegmentIndex: 0];
//      [segmentedControl setEnabled: NO forSegmentAtIndex: 1];
//   }
//   else if ([boardView blackIsInCheck]) {
//      [segmentedControl setSelectedSegmentIndex: 1];
//      [segmentedControl setEnabled: NO forSegmentAtIndex: 0];
//   }
//   else [segmentedControl setSelectedSegmentIndex: -1];
    
    [segmentedControl setSelectedSegmentIndex: -1];
    [contentView addSubview: segmentedControl];
    
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)donePressed {
   NSLog(@"Done");
    if ([segmentedControl selectedSegmentIndex] == -1){
//      [[[UIAlertView alloc] initWithTitle: @"Please select your side!"
//                                   message: @""
//                                  delegate: self
//                         cancelButtonTitle: nil
//                         otherButtonTitles: @"OK", nil]
//         show];
        [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool: 0 forKey: @"rotateBoard"];
        
        BoardViewController *bvc = [(ScanViewController *)[[self navigationController] viewControllers][0]boardViewController];
        [bvc editPositionDonePressed:fen];
        
    }else {
//      if ([[boardView maybeCastleString] isEqualToString: @"-"]) {
//         Square sqs[8];
//         int i;
//         i = [boardView epCandidateSquaresForColor:
//                           (Color)[segmentedControl selectedSegmentIndex]
//                                           toArray: sqs];
//         if (i == 0) {
       
             
            BoardViewController *bvc = [(ScanViewController *)[[self navigationController] viewControllers][0]boardViewController];
             
//             [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
             
             
             
             if ([segmentedControl selectedSegmentIndex] == 0) {
                 [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_BLACK];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setBool: 0 forKey: @"rotateBoard"];
             }else{
                 [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setBool: 1 forKey: @"rotateBoard"];
             }

//[bvc editPositionDonePressed:[NSString stringWithFormat: @"%@%c %@ -",[boardView boardString],(([segmentedControl selectedSegmentIndex] == 0)? 'w' : 'b'),[boardView maybeCastleString]]];
             [bvc editPositionDonePressed:fen];
             
//         }
       
#pragma-mark RETIREI A POSSIBILIDADE DE IR PARA A TELA DE MARCAR A CASA DE CAPTURA EN-PASSANT
//         else {
//            EpSquareController *epc =
//               [[EpSquareController alloc]
//                  initWithFen: [NSString stringWithFormat: @"%@%c %@ -",
//                                         [boardView boardString],
//                                         (([segmentedControl selectedSegmentIndex] == 0)? 'w' : 'b'),
//                                         [boardView maybeCastleString]]];
//            [[self navigationController] pushViewController: epc animated: YES];
//         }
//      }
       
#pragma-mark RETIREI A POSSIBILIDADE DE IR PARA A TELA DE MARCAR OS DIREITOS DE FAZER O ROQUE
//      else {
//         CastleRightsController *crc =
//            [[CastleRightsController alloc]
//               initWithFen: [NSString stringWithFormat: @"%@%c %@ -",
//                                      [boardView boardString],
//                                      (([segmentedControl selectedSegmentIndex] == 0)? 'w' : 'b'),
//                                      [boardView maybeCastleString]]];
//         [[self navigationController] pushViewController: crc animated: YES];
//      }
   }
}

@end
