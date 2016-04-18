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

#import <QuartzCore/QuartzCore.h>

#import "BoardViewController.h"
#import "GameController.h"
#import "GameDetailsTableController.h"
#import "LevelViewController.h"
#import "LoadFileListController.h"
#import "MoveListView.h"
#import "MoveTableViewController.h"
#import "Options.h"
#import "OptionsViewController.h"
#import "PGN.h"
#import "SetupViewController.h"
#import "ScanViewController.h"

@implementation BoardViewController

@synthesize analysisView, bookMovesView, boardView, whiteClockView, blackClockView, moveListView, gameController, searchStatsView, movesHistoryView;

/// init

- (id)init {
   if (self = [super init]) {
      [self setTitle:[[NSBundle mainBundle] infoDictionary][@"CFBundleName"]];
      iPadBoardRectLandscape = CGRectMake(5, 49-44, 640, 640);
      iPadWhiteClockRectLandscape = CGRectMake(656, 49-44, 176, 59);
      iPadBlackClockRectLandscape = CGRectMake(656+176+8, 49-44, 176, 59);
      iPadMoveListRectLandscape = CGRectMake(656, 116-44, 360, 573);
      iPadBookRectLandscape = CGRectMake(5, 695-44, 640, 20);
      iPadAnalysisRectLandscape = CGRectMake(5, 721-44, 1011, 20);
      iPadSearchStatsRectLandscape = CGRectMake(656, 695-44, 360, 20);
      
      iPadBoardRectPortrait = CGRectMake(8, 52-44, 752, 752);
      iPadWhiteClockRectPortrait = CGRectMake(8, 814-44, 185, 59);
      iPadBlackClockRectPortrait = CGRectMake(8, 881-44, 185, 59);
      iPadMoveListRectPortrait = CGRectMake(203, 814-44, 760-203, 126);
      iPadBookRectPortrait = CGRectMake(8, 948-44, 752, 20);
      iPadAnalysisRectPortrait = CGRectMake(8, 975-44, 440, 20);
      iPadSearchStatsRectPortrait = CGRectMake(458, 975-44, 302, 20);
   }
   
   return self;
}


/// loadView creates and lays out all the subviews of the main window: The
/// board, the toolbar, the move list, and the small UILabels used to display
/// the engine analysis and the clocks.

- (void)loadView {
    
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      BOOL portrait = UIInterfaceOrientationIsPortrait([self interfaceOrientation]);

#pragma INÍCIO DA CRIAÇÃO DE VIEW PARA IPAD
       
      // Content view
      CGRect appRect = [[UIScreen mainScreen] applicationFrame];
      rootView = [[RootView alloc] initWithFrame: appRect];
      [rootView setAutoresizesSubviews: YES];
      [rootView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight)];
      //[rootView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
      [rootView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      appRect.origin = CGPointMake(0.0f, 20.0f);

      contentView = [[UIView alloc] initWithFrame: appRect];
      [contentView setAutoresizesSubviews: YES];
      [contentView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleHeight)];
      //[contentView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
      [contentView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      [rootView addSubview: contentView];
      [self setView: rootView];

      // Board
      boardView = [[BoardView alloc] initWithFrame: portrait? iPadBoardRectPortrait : iPadBoardRectLandscape];
      boardView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      boardView.layer.borderWidth = 1.0;
      [contentView addSubview: boardView];

      // Clocks
      whiteClockView = [[UILabel alloc] initWithFrame: portrait? iPadWhiteClockRectPortrait : iPadWhiteClockRectLandscape];
      [whiteClockView setFont: [UIFont systemFontOfSize: 25.0]];
      [whiteClockView setTextAlignment: NSTextAlignmentCenter];
      [whiteClockView setText: @"White: 5:00"];
      [whiteClockView setBackgroundColor: [UIColor whiteColor]];
      whiteClockView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      whiteClockView.layer.borderWidth = 1.0;

      blackClockView = [[UILabel alloc] initWithFrame: portrait? iPadBlackClockRectPortrait : iPadBlackClockRectLandscape];
      [blackClockView setFont: [UIFont systemFontOfSize: 25.0]];
      [blackClockView setTextAlignment: NSTextAlignmentCenter];
      [blackClockView setText: @"Black: 5:00"];
      [blackClockView setBackgroundColor: [UIColor whiteColor]];
      blackClockView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      blackClockView.layer.borderWidth = 1.0;

      [contentView addSubview: whiteClockView];
      [contentView addSubview: blackClockView];

      // Move list
      moveListView =
         [[MoveListView alloc]
          initWithFrame: portrait? iPadMoveListRectPortrait : iPadMoveListRectLandscape];
      moveListView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      moveListView.layer.borderWidth = 1.0;
      [contentView addSubview: moveListView];

      // Book moves
      bookMovesView = [[UILabel alloc] initWithFrame: portrait? iPadBookRectPortrait : iPadBookRectLandscape];
      [bookMovesView setFont: [UIFont systemFontOfSize: 14.0]];
      [bookMovesView setBackgroundColor: [UIColor whiteColor]];
      bookMovesView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      bookMovesView.layer.borderWidth = 1.0;
      [contentView addSubview: bookMovesView];

      // Analysis
      analysisView = [[UILabel alloc] initWithFrame: portrait? iPadAnalysisRectPortrait : iPadAnalysisRectLandscape];
      [analysisView setFont: [UIFont systemFontOfSize: 14.0]];
      [analysisView setBackgroundColor: [UIColor whiteColor]];
      analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      analysisView.layer.borderWidth = 1.0;
      [contentView addSubview: analysisView];

      // Search stats
      searchStatsView = [[UILabel alloc] initWithFrame: portrait? iPadSearchStatsRectPortrait : iPadSearchStatsRectLandscape];
      [searchStatsView setFont: [UIFont systemFontOfSize: 14.0]];
      //[searchStatsView setTextAlignment: UITextAlignmentCenter];
      [searchStatsView setBackgroundColor: [UIColor whiteColor]];
      searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      searchStatsView.layer.borderWidth = 1.0;
      [contentView addSubview: searchStatsView];

      // Toolbar
      toolbar = [[UIToolbar alloc]
                 initWithFrame: CGRectMake(0, self.view.bounds.size.height-64, 1024, 44)];
      [contentView addSubview: toolbar];
      [toolbar setAutoresizingMask: UIViewAutoresizingFlexibleWidth];

      NSMutableArray *buttons = [[NSMutableArray alloc] init];
      UIBarButtonItem *button;
      UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

      button = [[UIBarButtonItem alloc] initWithTitle: @"Game"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
      //[button setWidth: 58.0f];
      [buttons addObject: button];
      gameButton = button;
      [buttons addObject: spacer];

      button = [[UIBarButtonItem alloc] initWithTitle: @"Options"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
      //[button setWidth: 60.0f];
      [buttons addObject: button];
      optionsButton = button;
      [buttons addObject: spacer];

      button = [[UIBarButtonItem alloc] initWithTitle: @"Flip"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
      [buttons addObject: button];
      [buttons addObject: spacer];

      button = [[UIBarButtonItem alloc] initWithTitle: @"Move"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
      //[button setWidth: 53.0f];
      [buttons addObject: button];
      moveButton = button;
      [buttons addObject: spacer];

      button = [[UIBarButtonItem alloc] initWithTitle: @"Hint"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
      //[button setWidth: 49.0f];
      [buttons addObject: button];

      //[buttons addObject: spacer];

      [toolbar setItems: buttons animated: YES];
      [toolbar sizeToFit];
      [toolbar setAutoresizingMask: UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
      
      [contentView bringSubviewToFront: boardView];

      // Activity indicator
      activityIndicator =
         [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0,0,30,30)];
      [activityIndicator setCenter: [boardView center]];
      [activityIndicator
         setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhite];
      [contentView addSubview: activityIndicator];
      [activityIndicator startAnimating];
   }
    
#pragma-mark INÍCIO DA CRIAÇÃO DE VIEW PARA IPHONE
    
   else { // iPhone or iPod touch
      // Content view
      CGRect appRect = [[UIScreen mainScreen] applicationFrame];
      rootView = [[RootView alloc] initWithFrame: appRect];
      
      CGPoint superCenter = CGPointMake(CGRectGetMidX([rootView bounds]), CGRectGetMidY([rootView bounds]));
       
      //[rootView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
      [rootView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      
      //appRect.origin = CGPointMake(0.0f, 20.0f);
      //appRect.size.height -= 20.0f;

      contentView = [[UIView alloc] initWithFrame: appRect];
      [rootView addSubview: contentView];
      [self setView: rootView];

      // Board
       
#pragma-mark ALTEREI O FRAME ONDE O TABULEIRO É POSICIONADO
//       boardView = [[BoardView alloc] initWithFrame: CGRectMake((appRect.size.width-appRect.size.width+40)/2, (self.view.frame.size.height/2)-(appRect.size.width/2+25), appRect.size.width-40, appRect.size.width-40)];
       
       boardView = [[BoardView alloc] initWithFrame: CGRectMake(0, 0, appRect.size.width-40, appRect.size.width-40)];
       
       [boardView setCenter:superCenter];
       
//      boardView =
//         [[BoardView alloc] initWithFrame: CGRectMake(0.0f, self.view.frame.size.height/4/*38.0f*//*18.0f*/, appRect.size.width, appRect.size.width)];
      [contentView addSubview: boardView];

      // Search stats
      searchStatsView =
         [[UILabel alloc] initWithFrame: CGRectMake(0.0f, /*20.0f*/0.0f, appRect.size.width, 18.0f)];
      [searchStatsView setFont: [UIFont systemFontOfSize: 14.0]];
      [searchStatsView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
#pragma-mark RETIREI A LINHA DE ESTATÍSTICAS DA INTELIGÊNCIA ARTIFICIAL
//      [contentView addSubview: searchStatsView];

      // Clocks
      whiteClockView =
         [[UILabel alloc] initWithFrame: CGRectMake(0.0f, /*20.0f*/ 0.0f, 0.5f * appRect.size.width, 18.0f)];
      [whiteClockView setFont: [UIFont systemFontOfSize: 14.0]];
      [whiteClockView setTextAlignment: NSTextAlignmentCenter];
      [whiteClockView setText: @"White: 5:00"];
      //[whiteClockView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
      [whiteClockView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      
      blackClockView =
         [[UILabel alloc] initWithFrame: CGRectMake(0.5f * appRect.size.width, /*20.0f*/ 0.0f, 0.5f * appRect.size.width, 18.0f)];
      [blackClockView setFont: [UIFont systemFontOfSize: 14.0]];
      [blackClockView setTextAlignment: NSTextAlignmentCenter];
      [blackClockView setText: @"Black: 5:00"];
      //[blackClockView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
      [blackClockView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      
#pragma-mark CRIEI UMA VIEW PARA ADICIONAR OS BOTÕES DE NAVEGAÇÃO ENTRE AS JOGADAS
       
       movesHistoryView =
       [[UIView alloc] initWithFrame: CGRectMake(0, 20.0f, appRect.size.width, 40.0f)];
//       [movesHistoryView setBackgroundColor:[UIColor blueColor]];
       
       //Botão para passar pra trás
       UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
       [btnBack addTarget:self
                      action:@selector(threadTakeBackMove)
            forControlEvents:UIControlEventTouchUpInside];
       [btnBack setTitle:@"\u25C2" forState:UIControlStateNormal];
       btnBack.titleLabel.font = [UIFont systemFontOfSize: 40];
       [btnBack setTitleColor:[UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1.0] forState:UIControlStateNormal];
       [btnBack setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
       
       btnBack.frame = CGRectMake(80.0f, 0, 40.0f, 40.0f);
//       [btnBack setBackgroundColor:[UIColor redColor]];
       [movesHistoryView addSubview:btnBack];
       
       [contentView addSubview: movesHistoryView];
       
       //Botão para passar pra frente
       UIButton *btnForward = [UIButton buttonWithType:UIButtonTypeCustom];
       [btnForward addTarget:self
                  action:@selector(threadReplayMove)
        forControlEvents:UIControlEventTouchUpInside];
       [btnForward setTitle:@"\u25B8" forState:UIControlStateNormal];
       btnForward.titleLabel.font = [UIFont systemFontOfSize: 40];
       [btnForward setTitleColor:[UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1.0] forState:UIControlStateNormal];
       [btnForward setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
       
       btnForward.frame = CGRectMake(200.0f, 0, 40.0f, 40.0f);
//       [btnForward setBackgroundColor:[UIColor redColor]];
       [movesHistoryView addSubview:btnForward];
       
      [contentView addSubview: movesHistoryView];
       
#pragma-mark RETIREI OS RELÓGIOS ACIMA DO TABULEIRO
//      [contentView addSubview: whiteClockView];
//      [contentView addSubview: blackClockView];

      // Analysis
      analysisView =
         [[UILabel alloc] initWithFrame: CGRectMake(0.0f, appRect.size.width + /*38.0f*/18.0f, appRect.size.width, 18.0f)];
      [analysisView setFont: [UIFont systemFontOfSize: 13.0]];
      //[analysisView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
      [analysisView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      CALayer* layer = [analysisView layer];
      CALayer *bottomBorder = [CALayer layer];
      bottomBorder.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
      bottomBorder.borderWidth = 1;
      bottomBorder.frame = CGRectMake(0, layer.frame.size.height-1, layer.frame.size.width, 0.5);
      [layer addSublayer:bottomBorder];
       
#pragma-mark RETIREI A LINHA DE ANÁLISE ABAIXO DO TABULEIRO
//      [contentView addSubview: analysisView];

      // Book moves. Shared with analysis view on the iPhone.
      bookMovesView = analysisView;

      // Move list
      float frameHeight = appRect.size.height;
      moveListView =
         [[MoveListView alloc]
            initWithFrame:
               CGRectMake(0.0f, appRect.size.width + /*56.0f*/ 36.0f, appRect.size.width,
                     frameHeight - appRect.size.width - /*56.0f*/ 36.0f - 44.0f)];
       
#pragma-mark RETIREI A LISTA DE MOVIMENTOS ABAIXO DO TABULEIRO
//       [contentView addSubview: moveListView];

      // Toolbar
      toolbar =
         [[UIToolbar alloc]
            initWithFrame: CGRectZero
               /*CGRectMake(0.0f, frameHeight-24.0f, appRect.size.width, 44.0f)*/];
      //[contentView addSubview: toolbar];
      
      UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

      NSMutableArray *buttons = [[NSMutableArray alloc] init];
      UIBarButtonItem *button;
      
#pragma-mark RETIRANDO ALGUNS BOTÕES DA TOOLBAR
       
      //[buttons addObject: spacer];
      button = [[UIBarButtonItem alloc] initWithTitle: @"Game"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
      [buttons addObject: button];
//      button = [[UIBarButtonItem alloc] initWithTitle: @"Options"
//                                                style: UIBarButtonItemStyleBordered
//                                               target: self
//                                               action: @selector(toolbarButtonPressed:)];
//      [buttons addObject: button];
      [buttons addObject: spacer];
      button = [[UIBarButtonItem alloc] initWithTitle: @"Flip"
                                                style: UIBarButtonItemStyleBordered
                                               target: self
                                               action: @selector(toolbarButtonPressed:)];
//      [buttons addObject: button];
//      [buttons addObject: spacer];
//      button = [[UIBarButtonItem alloc] initWithTitle: @"Move"
//                                                style: UIBarButtonItemStyleBordered
//                                               target: self
//                                               action: @selector(toolbarButtonPressed:)];
//      [buttons addObject: button];
//      [buttons addObject: spacer];
//      button = [[UIBarButtonItem alloc] initWithTitle: @"Hint"
//                                                style: UIBarButtonItemStyleBordered
//                                               target: self
//                                               action: @selector(toolbarButtonPressed:)];
      [buttons addObject: button];
      //[buttons addObject: spacer];

      [toolbar setItems: buttons animated: NO];
      [toolbar setTranslucent:NO];
      [toolbar setBarTintColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0]];
       
       [toolbar setTintColor:[UIColor whiteColor]];
      toolbar.frame = CGRectMake(0.0f, frameHeight-44.0f, appRect.size.width, 44.0f);
       
#pragma-mark ADIÇÃO DA TOOLBAR DE MENU
      [contentView addSubview: toolbar];
      //[toolbar sizeToFit];

      [contentView bringSubviewToFront: boardView];

      // Activity indicator
      activityIndicator =
         [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0,0,30,30)];
      [activityIndicator setCenter: CGPointMake(0.5f * appRect.size.width, (18.0f / 16.0f) * appRect.size.width)];
      [activityIndicator
         setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhite];
      [contentView addSubview: activityIndicator];
      [activityIndicator startAnimating];
   }

   // Action sheets for menus.
    
#pragma-mark ESTOU ALTERANDO O MENU GAME E A OPÇÃO Edit position PARA Scan new board
//   gameMenu = [[UIActionSheet alloc]
//                    initWithTitle: nil
//                         delegate: self
//                cancelButtonTitle: @"Cancel"
//                 destructiveButtonTitle: nil
//                otherButtonTitles: @"New game", @"Save game", @"Load game", @"E-mail game", @"Edit position", @"Level/Game mode", nil];
    
    gameMenu = [[UIActionSheet alloc]
                initWithTitle: nil
                delegate: self
                cancelButtonTitle: @"Cancel"
                destructiveButtonTitle: nil
                otherButtonTitles: @"Scan new board", nil];
    
   newGameMenu = [[UIActionSheet alloc] initWithTitle: nil
                                             delegate: self
                                    cancelButtonTitle: @"Cancel"
                               destructiveButtonTitle: nil
                                    otherButtonTitles:
                                           @"Play white", @"Play black", @"Play both", @"Analysis", nil];
   moveMenu = [[UIActionSheet alloc] initWithTitle: nil
                                          delegate: self
                                 cancelButtonTitle: @"Cancel"
                            destructiveButtonTitle: nil
                                 otherButtonTitles:
                                        @"Take back", @"Step forward", @"Take back all", @"Step forward all", @"Move list", @"Move now", nil];
   optionsMenu = nil;
   saveMenu = nil;
   emailMenu = nil;
   levelsMenu = nil;
   loadMenu = nil;
   moveListMenu = nil;
   popoverMenu = nil;
}


-(void)threadTakeBackMove{
    dispatch_async(dispatch_get_main_queue(), ^{[gameController takeBackMove];});
}

-(void)threadReplayMove{
    dispatch_async(dispatch_get_main_queue(), ^{[gameController replayMove];});
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      return YES;
   else
      return interfaceOrientation == UIInterfaceOrientationPortrait;
}


- (BOOL)shouldAutorotate {
   return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


- (NSUInteger)supportedInterfaceOrientations {
   return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
      UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration {
   //[rootView sizeToFit];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromOrientation {
   [boardView hideArrow];
   if ([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft ||
       [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight) {
      [boardView setFrame: iPadBoardRectLandscape];
      if (activityIndicator) [activityIndicator setCenter: [boardView center]];
      [whiteClockView setFrame: iPadWhiteClockRectLandscape];
      [blackClockView setFrame: iPadBlackClockRectLandscape];
      [moveListView setFrame: iPadMoveListRectLandscape];
      [bookMovesView setFrame: iPadBookRectLandscape];
      [analysisView setFrame: iPadAnalysisRectLandscape];
      [searchStatsView setFrame: iPadSearchStatsRectLandscape];
   }
   else {
      [boardView setFrame: iPadBoardRectPortrait];
      [whiteClockView setFrame: iPadWhiteClockRectPortrait];
      [blackClockView setFrame: iPadBlackClockRectPortrait];
      [moveListView setFrame: iPadMoveListRectPortrait];
      [bookMovesView setFrame: iPadBookRectPortrait];
      [analysisView setFrame: iPadAnalysisRectPortrait];
      [searchStatsView setFrame: iPadSearchStatsRectPortrait];
   }
   [gameController updateMoveList];
   [contentView bringSubviewToFront: toolbar];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
[super viewDidLoad];
}
*/

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)dealloc {

   // Why is this necessary for the move list menu, but not elsewhere?
   // I should try to find out. FIXME
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [moveListMenu dismissPopoverAnimated: YES];
      moveListMenu = nil;
   }
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
   if ([[alertView title] isEqualToString: @"Start new game?"]) {
      if (buttonIndex == 1)
         [gameController startNewGame];
   }
   else if ([[alertView title] isEqualToString:
                                  @"Exit Stockfish and send e-mail?"]) {
      if (buttonIndex == 1)
         [[UIApplication sharedApplication]
          openURL: [[NSURL alloc] initWithString: [gameController emailPgnString]]];

      /*
         [[UIApplication sharedApplication]
            openURL: [[NSURL alloc] initWithString:
                                       [gameController emailPgnString]]];
       */
   }
}


- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
   [actionSheet dismissWithClickedButtonIndex: buttonIndex animated: NO];
   NSString *buttonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];

   if (actionSheet == gameMenu) {
      if ([buttonTitle isEqualToString: @"New game"]) {
         dispatch_async(dispatch_get_main_queue(), ^{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
               [newGameMenu showFromBarButtonItem: gameButton animated: YES];
            else
               [newGameMenu showInView: contentView];
         });
      }
      else if ([buttonTitle isEqualToString: @"Save game"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [self showSaveGameMenu];
         });
      else if ([buttonTitle isEqualToString: @"Load game"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [self showLoadGameMenu];
         });
      else if ([buttonTitle isEqualToString: @"E-mail game"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [self showEmailGameMenu];
         });
      else if ([buttonTitle isEqualToString: @"Scan new board"])
         dispatch_async(dispatch_get_main_queue(), ^{
             [self scanNewPosition];
//            [self editPosition];
         });
      else if ([buttonTitle isEqualToString: @"Level/Game mode"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [self showLevelsMenu];
         });
   }
   else if (actionSheet == moveMenu) {
      if ([buttonTitle isEqualToString: @"Take back"]) {
          [self threadTakeBackMove];
      }
      else if ([buttonTitle isEqualToString: @"Step forward"]) {
          [self threadReplayMove];
      }
      else if ([buttonTitle isEqualToString: @"Take back all"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [gameController takeBackAllMoves];
         });
      else if ([buttonTitle isEqualToString: @"Step forward all"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [gameController replayAllMoves];
         });
      else if ([buttonTitle isEqualToString: @"Move list"])
         dispatch_async(dispatch_get_main_queue(), ^{
            [self showMoveListMenu];
         });
      else if ([buttonTitle isEqualToString: @"Move now"]) {
         dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Move now, computers turn %d, thinking %d", [gameController computersTurnToMove], [gameController engineIsThinking]);
            if ([gameController computersTurnToMove]) {
               if ([gameController engineIsThinking])
                  [gameController engineMoveNow];
               else
                  [gameController engineGo];
            }
            else
               [gameController startThinking];
         });
      }
   }
   else if (actionSheet == newGameMenu) {
      if ([buttonTitle isEqualToString: @"Play white"]) {
         NSLog(@"new game with white");
         [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_BLACK];
         [gameController setGameMode: GAME_MODE_COMPUTER_BLACK];
         [gameController startNewGame];
      }
      else if ([buttonTitle isEqualToString: @"Play black"]) {
         NSLog(@"new game with black");
         [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
         [gameController setGameMode: GAME_MODE_COMPUTER_WHITE];
         [gameController startNewGame];
      }
      else if ([buttonTitle isEqualToString: @"Play both"]) {
         NSLog(@"new game (both)");
         [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
         [gameController setGameMode: GAME_MODE_TWO_PLAYER];
         [gameController startNewGame];
      }
      else if ([buttonTitle isEqualToString: @"Analysis"]) {
         NSLog(@"new game (analysis)");
         [[Options sharedOptions] setGameMode: GAME_MODE_ANALYSE];
         [gameController setGameMode: GAME_MODE_ANALYSE];
         [gameController startNewGame];
      }
   }
}

- (void)toolbarButtonPressed:(id)sender {
   NSString *title = [sender title];

   // Ignore duplicate presses on the "Game" and "Move" buttons:
   if (([gameMenu isVisible] && [title isEqualToString: @"Game"]) ||
       ([moveMenu isVisible] && [title isEqualToString: @"Move"]))
      return;

   // Dismiss action sheet popovers, if visible:
   if ([gameMenu isVisible] && ![title isEqualToString: @"Game"])
      [gameMenu dismissWithClickedButtonIndex: -1 animated: YES];
   if ([newGameMenu isVisible])
      [newGameMenu dismissWithClickedButtonIndex: -1 animated: YES];
   if ([moveMenu isVisible])
      [moveMenu dismissWithClickedButtonIndex: -1 animated: YES];
   if (optionsMenu != nil) {
      [optionsMenu dismissPopoverAnimated: YES];
      optionsMenu = nil;
   }
   if (levelsMenu != nil) {
      [levelsMenu dismissPopoverAnimated: YES];
      levelsMenu = nil;
   }
   if (saveMenu != nil) {
      [saveMenu dismissPopoverAnimated: YES];
      saveMenu = nil;
   }
   if (emailMenu != nil) {
      [emailMenu dismissPopoverAnimated: YES];
      emailMenu = nil;
   }
   if (loadMenu != nil) {
      [loadMenu dismissPopoverAnimated: YES];
      loadMenu = nil;
   }
   if (moveListMenu != nil) {
      [moveListMenu dismissPopoverAnimated: YES];
      moveListMenu = nil;
   }
   if (popoverMenu != nil) {
      [popoverMenu dismissPopoverAnimated: YES];
      popoverMenu = nil;
   }

   if ([title isEqualToString: @"Game"]) {
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         [gameMenu showFromBarButtonItem: sender animated: YES];
      else
         [gameMenu showInView: contentView];
   }
   else if ([title isEqualToString: @"Options"])
      [self showOptionsMenu];
   else if ([title isEqualToString: @"Flip"])
      [gameController rotateBoard];
   else if ([title isEqualToString: @"Move"]) {
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         [moveMenu showFromBarButtonItem: sender animated: YES];
      else
         [moveMenu showInView: contentView];
   }
   else if ([title isEqualToString: @"Hint"])
      [gameController showHint];
   else if ([title isEqualToString: @"New"])
      [gameController startNewGame];
   else
      NSLog(@"%@", [sender title]);
}


- (void)showOptionsMenu {
   OptionsViewController *ovc;
   ovc = [[OptionsViewController alloc] initWithBoardViewController: self];
   navigationController =
      [[UINavigationController alloc]
         initWithRootViewController: ovc];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      optionsMenu = [[UIPopoverController alloc]
                       initWithContentViewController: navigationController];
      [optionsMenu presentPopoverFromBarButtonItem: optionsButton
                          permittedArrowDirections: UIPopoverArrowDirectionAny
                                          animated: YES];
   }
   else {
      CGRect r = [[navigationController view] frame];
      // Why do I suddenly have to use -20.0f for the Y coordinate below?
      // 0.0f seems right, and used to work in SDK 2.x.
      // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)optionsMenuDonePressed {
   NSLog(@"options menu done");
   if ([[Options sharedOptions] bookVarietyWasChanged])
      [gameController showBookMoves];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [optionsMenu dismissPopoverAnimated: YES];
      optionsMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)showLevelsMenu {
   NSLog(@"levels menu");
   LevelViewController *lvc;
   lvc = [[LevelViewController alloc] initWithBoardViewController: self];
   navigationController =
      [[UINavigationController alloc]
         initWithRootViewController: lvc];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      levelsMenu = [[UIPopoverController alloc]
                      initWithContentViewController: navigationController];
      [levelsMenu presentPopoverFromBarButtonItem: gameButton
                         permittedArrowDirections: UIPopoverArrowDirectionAny
                                         animated: YES];
   } else {
      CGRect r = [[navigationController view] frame];
      // Why do I suddenly have to use -20.0f for the Y coordinate below?
      // 0.0f seems right, and used to work in SDK 2.x.
      // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)levelWasChanged {
   [gameController setGameLevel: [[Options sharedOptions] gameLevel]];
}


- (void)gameModeWasChanged {
   [gameController setGameMode: [[Options sharedOptions] gameMode]];
}

- (void)levelsMenuDonePressed {
   NSLog(@"options menu done");

   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [levelsMenu dismissPopoverAnimated: YES];
      levelsMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}

- (void)scanNewPosition {
    
    ScanViewController *svc = [[ScanViewController alloc]init];
    svc = [[ScanViewController alloc]initWithBoardViewController:self];
    navigationController = [[UINavigationController alloc]initWithRootViewController: svc];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverMenu = [[UIPopoverController alloc]
                       initWithContentViewController: navigationController];
        //[popoverMenu setPopoverContentSize: CGSizeMake(320.0f, 460.0f)];
        [popoverMenu presentPopoverFromBarButtonItem: gameButton
                            permittedArrowDirections: UIPopoverArrowDirectionAny
                                            animated: NO];
    } else {
        CGRect r = [[navigationController view] frame];
        // Why do I suddenly have to use -20.0f for the Y coordinate below?
        // 0.0f seems right, and used to work in SDK 2.x.
        // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
        r.origin = CGPointMake(0.0f, 0.0f);
        [[navigationController view] setFrame: r];
        [rootView insertSubview: [navigationController view] atIndex: 0];
        [rootView flipSubviewsLeft];
    }
}

- (void)editPosition {
   SetupViewController *svc = [[SetupViewController alloc]initWithBoardViewController: self fen: [[gameController game] currentFEN]];
   navigationController = [[UINavigationController alloc] initWithRootViewController: svc];

   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      popoverMenu = [[UIPopoverController alloc]
                       initWithContentViewController: navigationController];
      //[popoverMenu setPopoverContentSize: CGSizeMake(320.0f, 460.0f)];
      [popoverMenu presentPopoverFromBarButtonItem: gameButton
                          permittedArrowDirections: UIPopoverArrowDirectionAny
                                          animated: NO];
   } else {
      CGRect r = [[navigationController view] frame];
      // Why do I suddenly have to use -20.0f for the Y coordinate below?
      // 0.0f seems right, and used to work in SDK 2.x.
      // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)editPositionCancelPressed {
   NSLog(@"edit position cancel");
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [popoverMenu dismissPopoverAnimated: YES];
      popoverMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)editPositionDonePressed:(NSString *)fen {
    NSLog(@"FEN Atual: %@", fen);

    if (Position::is_valid_fen([fen UTF8String])) {
        NSLog(@"É um FEN válido!");
    } else {
        NSLog(@"Não é um FEN válido.");
    }
    
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [popoverMenu dismissPopoverAnimated: YES];
      popoverMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
   [boardView hideLastMove];
   [boardView stopHighlighting];
   [gameController gameFromFEN: fen];
}


- (void)showSaveGameMenu {
   GameDetailsTableController *gdtc =
      [[GameDetailsTableController alloc]
         initWithBoardViewController: self
                                game: [gameController game]
                               email: NO];
   navigationController =
      [[UINavigationController alloc] initWithRootViewController: gdtc];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      saveMenu = [[UIPopoverController alloc]
                   initWithContentViewController: navigationController];
      [saveMenu presentPopoverFromBarButtonItem: gameButton
                       permittedArrowDirections: UIPopoverArrowDirectionAny
                                       animated: YES];
   } else {
      CGRect r = [[navigationController view] frame];
      // Why do I suddenly have to use -20.0f for the Y coordinate below?
      // 0.0f seems right, and used to work in SDK 2.x.
      // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)saveMenuDonePressed {
   if ([[[Options sharedOptions] saveGameFile] isEqualToString: @"Clipboard"]) {
      [[UIPasteboard generalPasteboard] setString: [[gameController game] pgnString]];
      UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle: @"" message:@"Your game was saved to the clipboard."
                                 delegate: nil
                        cancelButtonTitle: nil
                        otherButtonTitles: @"OK", nil];
      [alert show];
   } else {
      FILE *pgnFile =
         fopen([[PGN_DIRECTORY
                 stringByAppendingPathComponent: [[Options sharedOptions]
                                                  saveGameFile]] UTF8String],
              "a");
      if (pgnFile != NULL) {
         fprintf(pgnFile, "%s", [[[gameController game] pgnString] UTF8String]);
         fclose(pgnFile);
      }
   }
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [saveMenu dismissPopoverAnimated: YES];
      saveMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
   NSLog(@"save game done");
}


- (void)saveMenuCancelPressed {
   NSLog(@"save game canceled");
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [saveMenu dismissPopoverAnimated: YES];
      saveMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)showLoadGameMenu {
   LoadFileListController *lflc =
      [[LoadFileListController alloc] initWithBoardViewController: self];
   navigationController =
      [[UINavigationController alloc] initWithRootViewController: lflc];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      loadMenu = [[UIPopoverController alloc]
                    initWithContentViewController: navigationController];
      [loadMenu presentPopoverFromBarButtonItem: gameButton
                       permittedArrowDirections: UIPopoverArrowDirectionAny
                                       animated: YES];
   } else {
      CGRect r = [[navigationController view] frame];
      // Why do I suddenly have to use -20.0f for the Y coordinate below?
      // 0.0f seems right, and used to work in SDK 2.x.
      // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)loadMenuCancelPressed {
   NSLog(@"load game canceled");
   [[Options sharedOptions] setLoadGameFile: @""];
   [[Options sharedOptions] setLoadGameFileGameNumber: 0];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [loadMenu dismissPopoverAnimated: YES];
      loadMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)loadMenuDonePressedWithGame:(NSString *)gameString {
   NSLog(@"load menu done, gameString = %@", gameString);
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [loadMenu dismissPopoverAnimated: YES];
      loadMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
   [gameController gameFromPGNString: gameString
                   loadFromBeginning: YES];
   [boardView hideLastMove];
}


- (void)showEmailGameMenu {
   GameDetailsTableController *gdtc =
      [[GameDetailsTableController alloc]
         initWithBoardViewController: self
                                game: [gameController game]
                               email: YES];
   navigationController =
      [[UINavigationController alloc] initWithRootViewController: gdtc];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      emailMenu = [[UIPopoverController alloc]
                    initWithContentViewController: navigationController];
      [emailMenu presentPopoverFromBarButtonItem: gameButton
                        permittedArrowDirections: UIPopoverArrowDirectionAny
                                        animated: YES];
   } else {
      CGRect r = [[navigationController view] frame];
      // Why do I suddenly have to use -20.0f for the Y coordinate below?
      // 0.0f seems right, and used to work in SDK 2.x.
      // Update 2013-06-11: A value of 0.0f is suddenly right again in iOS 7.
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)emailMenuDonePressed {
   NSLog(@"email game done");
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [emailMenu dismissPopoverAnimated: YES];
      emailMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
   [[[UIAlertView alloc] initWithTitle: @"Exit Stockfish and send e-mail?"
                                message: @""
                               delegate: self
                      cancelButtonTitle: @"Cancel"
                      otherButtonTitles: @"OK", nil]
      show];
}


- (void)emailMenuCancelPressed {
   NSLog(@"email game canceled");
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [emailMenu dismissPopoverAnimated: YES];
      emailMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)showMoveListMenu {
   MoveTableViewController *mtvc = [[MoveTableViewController alloc]
                                        initWithBoardViewController: self
                                                               game: [gameController game]];
   navigationController = [[UINavigationController alloc]
                             initWithRootViewController: mtvc];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      moveListMenu = [[UIPopoverController alloc]
                        initWithContentViewController: navigationController];
      [moveListMenu presentPopoverFromBarButtonItem: moveButton
                           permittedArrowDirections: UIPopoverArrowDirectionAny
                                           animated: YES];
   } else {
      CGRect r = [[navigationController view] frame];
      r.origin = CGPointMake(0.0f, 0.0f);
      [[navigationController view] setFrame: r];
      [rootView insertSubview: [navigationController view] atIndex: 0];
      [rootView flipSubviewsLeft];
   }
}


- (void)moveListMenuDonePressed:(int)ply {
   if (ply >= 0)
      [gameController jumpToPly: ply animate: YES];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [moveListMenu dismissPopoverAnimated: YES];
      moveListMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)moveListMenuCancelPressed {
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [moveListMenu dismissPopoverAnimated: YES];
      moveListMenu = nil;
   } else {
      [rootView flipSubviewsRight];
      [[navigationController view] removeFromSuperview];
   }
}


- (void)stopActivityIndicator {
   if (activityIndicator) {
      [activityIndicator stopAnimating];
      [activityIndicator removeFromSuperview];
      activityIndicator = nil;
   }
}


- (void)hideAnalysis {
   [analysisView setText: @""];
   [searchStatsView setText: @""];
   if ([[Options sharedOptions] showBookMoves])
      [gameController showBookMoves];
}


- (void)hideBookMoves {
   if ([[analysisView text] hasPrefix: @"  Book"])
      [analysisView setText: @""];
}


- (void)showBookMoves {
   [gameController showBookMoves];
}



@end
