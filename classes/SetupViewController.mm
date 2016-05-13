/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import "BoardViewController.h"
#import "Options.h"
#import "SelectedPieceView.h"
#import "SetupBoardView.h"
#import "SetupViewController.h"
#import "SideToMoveController.h"
#import "ScanViewController.h"

@implementation SetupViewController

@synthesize boardViewController, scanViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc
                              fen:(NSString *)aFen {
   if (self = [super init]) {
      [self setTitle: @"Board"];
      boardViewController = bvc;
      fen = aFen;
      [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
   }
   return self;
}

- (id)initWithScanViewController:(ScanViewController *)svc
                              fen:(NSString *)aFen {
    if (self = [super init]) {
        [self setTitle: @"Board"];
        scanViewController = svc;
        fen = aFen;
        [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
    }
    return self;
}


- (void)loadView {
    [super loadView];
    
   UIView *contentView;
    
   CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    
   CGRect r = [[UIScreen mainScreen] applicationFrame];
   contentView = [[UIView alloc] initWithFrame: r];
   [self setView: contentView];
   [contentView setBackgroundColor: [UIColor colorWithRed: 0.934 green: 0.934 blue: 0.953 alpha: 1.0]];

   // Create a UISegmentedControl as a menu at the top of the screen
   NSArray *buttonNames = @[@"CANCEL", @"NEXT"];
   menu = [[UISegmentedControl alloc] initWithItems: buttonNames];
   [menu setTintColor:[UIColor whiteColor]];
    
    
   [menu setMomentary: YES];
   //[menu setSegmentedControlStyle: UISegmentedControlStyleBar];
   [menu setFrame: CGRectMake(10.0f, 2.0f, 300.0f, 40.0f)];
   [menu addTarget: self
            action: @selector(buttonPressed:)
         forControlEvents: UIControlEventValueChanged];
//   [[self navigationItem] setTitleView: menu];
    
    UIView *toolbar = [[UIView alloc]init];
    [toolbar setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0]];
    toolbar.frame = CGRectMake(0.0f, appRect.size.height-25, appRect.size.width, 65.0f);
    
    menu.tintColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0];
    [menu setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    [toolbar addSubview:menu];
    [contentView addSubview:toolbar];
   
   BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

   // Selected piece view
   SelectedPieceView *spv;

   // I have no idea why, but the vertical view coordinates are different in
   // iOS 7 and iOS 8. We need to compensate for this to be able to handle both
   // OS versions correctly.
   BOOL isRunningiOS7 = [UIDevice currentDevice].systemVersion.floatValue < 8.0f;
   float sqSize;
   float dy = isIpad ? 50.0f : 64.0f;
   if (isIpad && isRunningiOS7) dy -= 34.0f;
   
   if (isIpad) {
      sqSize = 40.0f;
      spv = [[SelectedPieceView alloc] initWithFrame:CGRectMake(40.0f, 320.0f + dy, 240.0f, 80.0f)];
   } else {
      sqSize = [UIScreen mainScreen].applicationFrame.size.width / 8.0f;
      spv = [[SelectedPieceView alloc]
            initWithFrame:CGRectMake(40.0f, 8*sqSize + 74.0f, 6*sqSize, 2*sqSize)];
   }
   [contentView addSubview: spv];

   // Setup board view
   dy = isIpad ? 40.0f : 64.0f;
   if (isIpad && isRunningiOS7) dy -= 34.0f;
   boardView = [[SetupBoardView alloc]initWithController: self frame: CGRectMake(0.0f, dy, 8*sqSize, 8*sqSize)fen: fen phase: PHASE_EDIT_BOARD];
   [contentView addSubview: boardView];
   [boardView setSelectedPieceView: spv];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)buttonPressed:(id)sender {
    
    [[Options sharedOptions] setGameLevel: LEVEL_2S_PER_MOVE];
    [boardViewController levelWasChanged];
    
   switch([sender selectedSegmentIndex]) {
   case 0:
      [boardViewController editPositionCancelPressed];
      break;
   case 1:
      SideToMoveController *stmc = [[SideToMoveController alloc]
                                      initWithFen: [boardView fen]];
      [[self navigationController] pushViewController: stmc animated: YES];
      break;
   }
}


- (void)disableDoneButton {
   [menu setEnabled: NO forSegmentAtIndex: 1];
}



- (void)enableDoneButton {
   [menu setEnabled: YES forSegmentAtIndex: 1];
}




@end
