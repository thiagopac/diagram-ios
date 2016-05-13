/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
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
#import "Constants.h"

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
//    [contentView addSubview: warningLabel];

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
    [nextButton addTarget:self action:@selector(bothPressed) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"PLAY BOTH SIDES" forState:UIControlStateNormal];
    [nextButton setBackgroundColor:[constants colorRED]];
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
    
    btnWhite = [[UIButton alloc]init];
    [btnWhite setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnWhite setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
//    UIImage *btnImageWhite = [UIImage imageNamed:@"AlphaWKing.png"];
//    [btnWhite setImage:btnImageWhite forState:UIControlStateNormal];
    [btnWhite setTitle:@"WHITE" forState:UIControlStateNormal];
    [btnWhite setBackgroundColor:[UIColor whiteColor]];
    [btnWhite addTarget:self action:@selector(btnWhiteTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnWhite.frame = CGRectMake(0.0f, r.size.height-70, r.size.width/2, 45.0f);
    
    btnBlack = [[UIButton alloc]init];
    [btnBlack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBlack setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
//    UIImage *btnImageBlack = [UIImage imageNamed:@"AlphaBKing.png"];
//    [btnBlack setImage:btnImageBlack forState:UIControlStateNormal];
    [btnBlack setTitle:@"BLACK" forState:UIControlStateNormal];
    [btnBlack setBackgroundColor:[constants colorBLACK]];
    [btnBlack addTarget:self action:@selector(btnBlackTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnBlack.frame = CGRectMake(r.size.width/2, r.size.height-70, r.size.width/2, 45.0f);
    
    [contentView addSubview:btnWhite];
    [contentView addSubview:btnBlack];
    
    
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
//    [contentView addSubview: segmentedControl];
    
}

- (void)btnWhiteTapped:(UIButton *)sender {
    
    [btnWhite setSelected:YES];
    [btnBlack setSelected:NO];
    [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_BLACK];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: 0 forKey: @"rotateBoard"];
    [self goToBoard];
}

- (void)btnBlackTapped:(UIButton *)sender {
    
    [btnWhite setSelected:NO];
    [btnBlack setSelected:YES];
    [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: 1 forKey: @"rotateBoard"];
    [self goToBoard];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)bothPressed {
   
    [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: 0 forKey: @"rotateBoard"];
    
    [self goToBoard];
        
}

-(void)goToBoard{
    BoardViewController *bvc = [(ScanViewController *)[[self navigationController] viewControllers][0]boardViewController];
    [bvc editPositionDonePressed:fen];
}

@end
