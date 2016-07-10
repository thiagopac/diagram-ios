/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <QuartzCore/QuartzCore.h>
#import "constants.h"
#import "BoardViewController.h"
#import "GameController.h"
#import "MoveListView.h"
#import "Options.h"
#import "PGN.h"
#import "ScanViewController.h"
#import "SGActionView.h"

@implementation BoardViewController

@synthesize boardView, contentView, moveListView, gameController, movesHistoryView, activityIndicator;

- (void)loadView {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startActivityIndicator) name:@"startActivityIndicator" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopActivityIndicator) name:@"stopActivityIndicator" object:nil];

      // Content view
      CGRect appRect = [[UIScreen mainScreen] applicationFrame];
      rootView = [[RootView alloc] initWithFrame: appRect];
      [rootView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
      
      contentView = [[UIView alloc] initWithFrame: appRect];
      [rootView addSubview: contentView];
      [self setView: rootView];

       boardView = [[BoardView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, appRect.size.width, appRect.size.width)];
      [contentView addSubview: boardView];
       
       movesHistoryView = [[UIView alloc] initWithFrame: CGRectMake(0, appRect.size.width, appRect.size.width, 40.0f)];
       [movesHistoryView setBackgroundColor:[UIColor colorWithRed:0.13 green:0.18 blue:0.22 alpha:1.0]];

       //Botão para voltar tudo
       UIButton *btnBackAll = [UIButton buttonWithType:UIButtonTypeCustom];
       [btnBackAll addTarget:self action:@selector(threadTakeBackAllMoves) forControlEvents:UIControlEventTouchUpInside];
       [btnBackAll setTitle:@"\u25C2\u25C2" forState:UIControlStateNormal];
       btnBackAll.titleLabel.font = [UIFont systemFontOfSize: 30];
       [btnBackAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       [btnBackAll setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
       btnBackAll.frame = CGRectMake(appRect.size.width/2-140.0f, 0, 60.0f, 30.0f);
    
//    [btnBackAll setBackgroundColor:[UIColor redColor]];
       [movesHistoryView addSubview:btnBackAll];
       
       //Botão para passar pra trás
       UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
       [btnBack addTarget:self action:@selector(threadTakeBackMove) forControlEvents:UIControlEventTouchUpInside];
       [btnBack setTitle:@"\u25C2" forState:UIControlStateNormal];
       btnBack.titleLabel.font = [UIFont systemFontOfSize: 30];
       [btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       [btnBack setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
       btnBack.frame = CGRectMake(appRect.size.width/2-60.0f, 0, 40.0f, 30.0f);
    
//    [btnBack setBackgroundColor:[UIColor redColor]];
       [movesHistoryView addSubview:btnBack];
       
       //Botão para passar pra frente
       UIButton *btnForward = [UIButton buttonWithType:UIButtonTypeCustom];
       [btnForward addTarget:self action:@selector(threadReplayMove) forControlEvents:UIControlEventTouchUpInside];
       [btnForward setTitle:@"\u25B8" forState:UIControlStateNormal];
       btnForward.titleLabel.font = [UIFont systemFontOfSize: 30];
       [btnForward setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       [btnForward setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
       btnForward.frame = CGRectMake(appRect.size.width/2+20.0f, 0, 40.0f, 30.0f);
    
//    [btnForward setBackgroundColor:[UIColor redColor]];
       [movesHistoryView addSubview:btnForward];
       
       //Botão para avançar tudo
       UIButton *btnForwardAll = [UIButton buttonWithType:UIButtonTypeCustom];
       [btnForwardAll addTarget:self action:@selector(threadReplayAllMoves) forControlEvents:UIControlEventTouchUpInside];
       [btnForwardAll setTitle:@"\u25B8\u25B8" forState:UIControlStateNormal];
       btnForwardAll.titleLabel.font = [UIFont systemFontOfSize: 30];
       [btnForwardAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       [btnForwardAll setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
       btnForwardAll.frame = CGRectMake(appRect.size.width/2+80.0f, 0, 60.0f, 30.0f);
    
//    [btnForwardAll setBackgroundColor:[UIColor redColor]];
       [movesHistoryView addSubview:btnForwardAll];
       [contentView addSubview: movesHistoryView];

      // Move list
      float frameHeight = appRect.size.height;
      moveListView = [[MoveListView alloc]initWithFrame:CGRectMake(0.0f, appRect.size.width + /*56.0f*/ 36.0f, appRect.size.width,frameHeight - appRect.size.width - /*56.0f*/ 36.0f - 44.0f)];
      [contentView addSubview: moveListView];

      // Toolbar
      toolbar = [[UIToolbar alloc]initWithFrame: CGRectZero];
      
      UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

      NSMutableArray *buttons = [[NSMutableArray alloc] init];
      UIBarButtonItem *button;
    
       UIImage *imageGame = [UIImage imageNamed:@"btnGame.png"];
       
       button = [[UIBarButtonItem alloc] initWithImage:imageGame style:UIBarButtonItemStylePlain target:self action:@selector(toolbarButtonPressed:)];
       [button setTag:10];
       
      [buttons addObject: button];

      [buttons addObject: spacer];
       
       UIImage *imageName = [UIImage imageNamed:@"name.png"];
       button = [[UIBarButtonItem alloc] initWithImage:imageName style:UIBarButtonItemStylePlain target:self action:nil];
       

       [buttons addObject: button];
       [buttons addObject: spacer];
       
       UIImage *imageFlip = [[UIImage imageNamed:@"btnFlip.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
       
       button = [[UIBarButtonItem alloc] initWithImage:imageFlip style:UIBarButtonItemStylePlain target:self action:@selector(toolbarButtonPressed:)];
       [button setTag:20];

      [buttons addObject: button];

      [toolbar setItems: buttons animated: NO];
      [toolbar setTranslucent:NO];
      [toolbar setBarTintColor:[constants colorRED]];
       
       [toolbar setTintColor:[UIColor whiteColor]];
      toolbar.frame = CGRectMake(0.0f, frameHeight-44.0f, appRect.size.width, 44.0f);
       
#pragma-mark ADIÇÃO DA TOOLBAR DE MENU
      [contentView addSubview: toolbar];
      //[toolbar sizeToFit];

      [contentView bringSubviewToFront: boardView];

      // Activity indicator
      self.activityIndicator =
         [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0,0,30,30)];
      [self.activityIndicator setCenter: CGPointMake(0.5f * appRect.size.width, appRect.size.width + 18.0f)];
      [self.activityIndicator
         setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhite];
      [contentView addSubview: self.activityIndicator];
      [self.activityIndicator setHidesWhenStopped:YES];
      [self startActivityIndicator];
  
    
    gameMenu = [[UIActionSheet alloc]
                initWithTitle: nil
                delegate: self
                cancelButtonTitle: @"Cancel"
                destructiveButtonTitle: nil
                otherButtonTitles: @"Scan new board", @"Play as White", @"Play as Black", @"Play both", nil];
}

-(void)threadTakeBackAllMoves{
    dispatch_async(dispatch_get_main_queue(), ^{[gameController takeBackAllMoves];});
}

-(void)threadTakeBackMove{
    dispatch_async(dispatch_get_main_queue(), ^{[gameController takeBackMove];});
}

-(void)threadReplayMove{
    dispatch_async(dispatch_get_main_queue(), ^{[gameController replayMove];});
}


-(void)threadReplayAllMoves{
    dispatch_async(dispatch_get_main_queue(), ^{[gameController replayAllMoves];});
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Release anything that's not essential, such as cached data
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
   [actionSheet dismissWithClickedButtonIndex: buttonIndex animated: NO];
   NSString *buttonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];

   if (actionSheet == gameMenu) {
      if ([buttonTitle isEqualToString: @"Scan new board"])
         dispatch_async(dispatch_get_main_queue(), ^{
             [self scanNewPosition];
         });
      else if ([buttonTitle isEqualToString: @"Play as White"])
       dispatch_async(dispatch_get_main_queue(), ^{
           [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_BLACK];
           [gameController setGameMode: GAME_MODE_COMPUTER_BLACK];
           [boardView hideLastMove];
        });
      else if ([buttonTitle isEqualToString: @"Play as Black"])
       dispatch_async(dispatch_get_main_queue(), ^{
           [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
           [gameController setGameMode: GAME_MODE_COMPUTER_WHITE];
           [boardView hideLastMove];
       });
      else if ([buttonTitle isEqualToString: @"Play both"])
       dispatch_async(dispatch_get_main_queue(), ^{
           [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
           [gameController setGameMode: GAME_MODE_TWO_PLAYER];
           [boardView hideLastMove];
       });
   }
}

- (void)loadMenuDonePressedWithGame:(NSString *)gameString {
    NSLog(@"load menu done, gameString = %@", gameString);
    [rootView flipSubviewsRight];
    [[navigationController view] removeFromSuperview];
    [gameController gameFromPGNString: gameString loadFromBeginning: YES];
    [boardView hideLastMove];
}

- (void)toolbarButtonPressed:(id)sender {

   NSInteger tag = [sender tag];

   if (tag == 10)
     [gameMenu showInView: contentView];
   else if (tag == 20)
     [gameController rotateBoard];
}

- (void)levelWasChanged {
   [gameController setGameLevel: [[Options sharedOptions] gameLevel]];
}

- (void)gameModeWasChanged {
   [gameController setGameMode: [[Options sharedOptions] gameMode]];
}

- (void)scanNewPosition {
    
    ScanViewController *svc = [[ScanViewController alloc]init];
    svc = [[ScanViewController alloc]initWithBoardViewController:self];
    navigationController = [[UINavigationController alloc]initWithRootViewController: svc];
    
    CGRect r = [[navigationController view] frame];
    r.origin = CGPointMake(0.0f, 0.0f);
    [[navigationController view] setFrame: r];
    [rootView insertSubview: [navigationController view] atIndex: 0];
    [rootView flipSubviewsLeft];
}


- (void)editPositionCancelPressed {
   NSLog(@"edit position cancel");
  [rootView flipSubviewsRight];
  [[navigationController view] removeFromSuperview];
}

- (void)editPositionDonePressed:(NSString *)fen {
    [rootView flipSubviewsRight];
    [[navigationController view] removeFromSuperview];
    [boardView hideLastMove];
    [boardView stopHighlighting];
    [gameController gameFromFEN: fen];
}

- (void)startActivityIndicator {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator startAnimating];
        });
    });
}

- (void)hideLastMove{
    [boardView hideLastMove];
}

- (void)stopActivityIndicator {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
        });
    });
}

@end
