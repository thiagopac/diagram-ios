/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "AnimatedGameView.h"
#import "BoardViewController.h"
#import "ColorUtils.h"
#import "Game.h"
#import "GamePreview.h"
#import "GameListController.h"
#import "LoadFileListController.h"
#import "Options.h"
#import "PGN.h"


// Class for the table header view

@interface GameHeaderView : UIView {
   AnimatedGameView *animatedGameView;
}

@property (nonatomic, strong) AnimatedGameView *animatedGameView;
@end

@implementation GameHeaderView
@synthesize animatedGameView;

- (void)dealloc {
   NSLog(@"GameHeaderView dealloc");
   [animatedGameView stopAnimation];
}

@end // End of GameHeaderView class



@interface GamePreview()

-(void)buttonPressed:(UIButton *)button;
- (GameHeaderView *)createHeaderView;
- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gr;

@end


@implementation GamePreview

- (id) initWithPGN:(PGN *)pgn gameNumber:(int)aNumber
gameListController:(GameListController *)glc
        isReadonly:(BOOL)readonly{
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      pgnFile = pgn;
      gameNumber = aNumber;
      gameListController = glc;
      [pgnFile goToGameNumber: gameNumber];
      isReadonly = readonly;

      // HACK: Because this view is not yet initialized, it seems we can't ask for its tint color.
      // Create a bogus UIView to get the default tint color.
      UIColor *color = [UIColor systemTintColor];

      UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f, 50.0f), NO, [UIScreen mainScreen].scale);
      CGContextRef ctx = UIGraphicsGetCurrentContext();
      CGContextSaveGState(ctx);
      CGContextSetStrokeColorWithColor(ctx, color.CGColor);
      CGContextSetLineWidth(ctx, 3.0f);
      CGContextMoveToPoint(ctx, 25.0, 17.0);
      CGContextAddLineToPoint(ctx, 15.0, 27.0);
      CGContextAddLineToPoint(ctx, 25.0, 37.0);
      CGContextStrokePath(ctx);
      CGContextRestoreGState(ctx);
      backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();

      UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f, 50.0f), NO, [UIScreen mainScreen].scale);
      ctx = UIGraphicsGetCurrentContext();
      CGContextSaveGState(ctx);
      CGContextSetStrokeColorWithColor(ctx, color.CGColor);
      CGContextSetLineWidth(ctx, 3.0f);
      CGContextMoveToPoint(ctx, 25.0, 17.0);
      CGContextAddLineToPoint(ctx, 35.0, 27.0);
      CGContextAddLineToPoint(ctx, 25.0, 37.0);
      CGContextStrokePath(ctx);
      CGContextRestoreGState(ctx);
      forwardButtonImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();

   }
   return self;
}


- (void)loadView {
   [super loadView];
   [[self navigationItem] setRightBarButtonItem:
                             [[UIBarButtonItem alloc]
                                 initWithTitle: @"Load game"
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(loadButtonPressed)]];

   headerView = [self createHeaderView];
   [[self tableView] setTableHeaderView: headerView];
   [[self tableView] setScrollEnabled: NO];
   [[self tableView] setAllowsSelection: NO];
}


- (void)viewDidAppear:(BOOL)animated {
   if ([[Options sharedOptions] displayGamePreviewSwipingHint])
      [[[UIAlertView alloc] initWithTitle: @"Hint:"
                                   message: @"Swipe right/left or press the buttons to jump to the next or previous game. Swipe up to permanently delete the current game from the database."
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
    show];
}

- (GameHeaderView *)createHeaderView {
   float width = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 320.0f : self.view.frame.size.width;
   BOOL tallScreen = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad &&
         [UIScreen mainScreen].applicationFrame.size.height > 480.0f;
   BOOL bigScreen = tallScreen &&
         [UIScreen mainScreen].applicationFrame.size.width > 320.0f;
   float boardWidth = bigScreen ? 0.75f * width : tallScreen ? 0.65f * width : 0.5f * width;
   float dy = bigScreen ? 14.0f : tallScreen ? 6.0f : 0.0f;

   GameHeaderView *view = [[GameHeaderView alloc]
         initWithFrame: CGRectMake(0, 0, width, boardWidth + (tallScreen ? 66 : 46) + 2 * dy)];
   [view setBackgroundColor: [UIColor clearColor]];
   
   Game *g = [[Game alloc] initWithGameController: nil
                                        PGNString: [pgnFile pgnStringForGameNumber:
                                                    gameNumber]];
   AnimatedGameView *agv = [[AnimatedGameView alloc]
         initWithGame: g
                frame: CGRectMake(0.5f*(width - boardWidth), 10 + dy, boardWidth, boardWidth)];
   [view addSubview: agv];
   [view setAnimatedGameView: agv];
   
   UILabel *label = [[UILabel alloc]
         initWithFrame: CGRectMake(0, 14 + boardWidth + dy, width, 20)];
   [label setText: [NSString stringWithFormat: @"%@-%@ %@ (%d moves)",
                    [g whitePlayer], [g blackPlayer], [g result], (int)([[g moves] count] + 1) / 2]];
   [label setFont: [UIFont systemFontOfSize: 12]];
   [label setTextAlignment: NSTextAlignmentCenter];
   [view addSubview: label];
   if (tallScreen && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
      [g computeOpeningString];
      label = [[UILabel alloc]
            initWithFrame: CGRectMake(0, 14 + boardWidth + 20 + dy, width, 20)];
      [label setText: [g openingString]];
      [label setFont: [UIFont systemFontOfSize: 12]];
      [label setTextAlignment: NSTextAlignmentCenter];
      [view addSubview: label];
   }
   
   if (gameNumber == 0)
      backButton = nil;
   else {
      backButton = [[UIButton alloc] initWithFrame:
            CGRectMake(0.25f*(width-boardWidth) - 25, 10 + 0.5f*boardWidth - 25 + dy, 50, 50)];
      [backButton setImage: backButtonImage forState: UIControlStateNormal];
      [view addSubview: backButton];
      [backButton addTarget: self
                     action: @selector(buttonPressed:)
           forControlEvents: UIControlEventTouchDown];
   }
   
   if (gameNumber + 1 == [pgnFile numberOfFilteredGames])
      forwardButton = nil;
   else {
      forwardButton = [[UIButton alloc]
          initWithFrame: CGRectMake(
            width - 0.25f*(width-boardWidth) - 25, 10 + 0.5f*boardWidth - 25 + dy, 50, 50)];
      [forwardButton setImage: forwardButtonImage forState: UIControlStateNormal];
      [view addSubview: forwardButton];
      [forwardButton addTarget: self
                        action: @selector(buttonPressed:)
              forControlEvents: UIControlEventTouchDown];
   }
   [agv startAnimation];

   UISwipeGestureRecognizer *gr;
   
   gr = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(handleSwipeGesture:)];
   [gr setDirection: UISwipeGestureRecognizerDirectionLeft];
   [view addGestureRecognizer: gr];
   
   gr = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(handleSwipeGesture:)];
   [gr setDirection: UISwipeGestureRecognizerDirectionRight];
   [view addGestureRecognizer: gr];
   
   gr = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(handleSwipeGesture:)];
   [gr setDirection: UISwipeGestureRecognizerDirectionUp];
   [view addGestureRecognizer: gr];
   
   return view;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   return 4 /*7*/;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   NSInteger section = [indexPath section];

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil)
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                     reuseIdentifier: @"cell"];

   if (section == 0) {
      /*
      if(row == 0) {
         [[cell textLabel] setText: @"White"];
         [[cell detailTextLabel] setText: [pgnFile white]];
      }
      else if(row == 1) {
         [[cell textLabel] setText: @"Black"];
         [[cell detailTextLabel] setText: [pgnFile black]];
      }
      */
      /*else*/ if (row == 0 /*2*/) {
         [[cell textLabel] setText: @"Event"];
         [[cell detailTextLabel] setText: [pgnFile event]];
      }
      else if (row == 1 /*3*/) {
         [[cell textLabel] setText: @"Site"];
         [[cell detailTextLabel] setText: [pgnFile site]];
      }
      else if (row == 2 /*4*/) {
         [[cell textLabel] setText: @"Date"];
         [[cell detailTextLabel] setText: [pgnFile date]];
      }
      else if (row == 3 /*5*/) {
         [[cell textLabel] setText: @"Round"];
         [[cell detailTextLabel] setText: [pgnFile round]];
      }
      /*
      else if (row == 6) {
         [[cell textLabel] setText: @"Result"];
         [[cell detailTextLabel] setText: [pgnFile result]];
      }
      */
   }
   return cell;
}


-(void)buttonPressed:(UIButton *)button {
   int direction = (button == forwardButton)? 1 : -1;
   gameNumber += direction;
   [pgnFile goToGameNumber: gameNumber];
   
   [UIView animateWithDuration: 0.25 animations: ^{
      [headerView setFrame: CGRectMake(-direction * 290, 0, 320, 206)];
   } completion: ^(BOOL finished) {
      [[self tableView] reloadData];
      headerView = [self createHeaderView];
      [[self tableView] setTableHeaderView: headerView];
      [headerView setFrame: CGRectMake(direction * 290, 0, 320, 206)];
      [UIView animateWithDuration: 0.3
                            delay: 0
           usingSpringWithDamping: 0.72
            initialSpringVelocity: 5
                          options: 0
                       animations: ^{
                          [headerView setFrame: CGRectMake(0, 0, 320, 206)];
                       } completion: nil];
   }];
}


- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gr {
   if ([gr direction] == UISwipeGestureRecognizerDirectionLeft &&
       gameNumber + 1 < [pgnFile numberOfFilteredGames])
      [self buttonPressed: forwardButton];
   else if ([gr direction] == UISwipeGestureRecognizerDirectionRight &&
            gameNumber > 0)
      [self buttonPressed: backButton];
   else if ([gr direction] == UISwipeGestureRecognizerDirectionUp) {
      if (isReadonly) {
         [[[UIAlertView alloc] initWithTitle: @""
                                      message: @"This game belongs to a read-only file, and cannot be deleted."
                                     delegate: self
                            cancelButtonTitle: nil
                            otherButtonTitles: @"OK", nil]
          show];
      }
      else if ([pgnFile filterIsActive]) {
         [[[UIAlertView alloc] initWithTitle: @""
                                      message: @"Deletion of games in databases filtered by a search is currently not supported. This problem will be fixed in a future version. We apologize for the inconvenience."
                                     delegate: self
                            cancelButtonTitle: nil
                            otherButtonTitles: @"OK", nil]
          show];
      }
      else {
         [[[UIAlertView alloc] initWithTitle: @"Delete game?"
                                      message: @"You cannot undo this action."
                                     delegate: self
                            cancelButtonTitle: @"Cancel"
                            otherButtonTitles: @"OK", nil]
          show];
      }
   }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if (isReadonly) return;
   if ([pgnFile filterIsActive]) return;
   if ([[alertView title] isEqualToString: @"Hint:"]) return;
   if (buttonIndex == 1) { // OK
      BOOL lastGame = gameNumber + 1 == [pgnFile numberOfFilteredGames];
      
      // Delete game from PGN file
      [pgnFile deleteGameNumber: gameNumber];
      
      // Update parent view controller
      [[gameListController tableView]
       deleteRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: gameNumber inSection: 0]]
             withRowAnimation:UITableViewRowAnimationNone];

      // Slide old header view up and out of the frame
      [UIView animateWithDuration: 0.3 animations: ^{
         [headerView setFrame: CGRectMake(0, -206, 320, 206)];
      } completion: ^(BOOL finished) {
         // If no games remain, pop out to parent view controller
         if ([pgnFile numberOfFilteredGames] == 0) {
            NSLog(@"GamePreview: popping out");
            [[self navigationController] popViewControllerAnimated: YES];
            return;
         }
         int direction = lastGame? -1 : 1;
         if (lastGame) gameNumber--;
         [[self tableView] reloadData];
         headerView = [self createHeaderView];
         [[self tableView] removeFromSuperview];
         [[self tableView] setTableHeaderView: headerView];
         [headerView setFrame: CGRectMake(direction * 290, 0, 320, 206)];
         [UIView animateWithDuration: 0.3
                               delay: 0
              usingSpringWithDamping: 0.72
               initialSpringVelocity: 5
                             options: 0
                          animations: ^{
                             [headerView setFrame: CGRectMake(0, 0, 320, 206)];
                          } completion: nil];
      }];
   }
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   [tableView deselectRowAtIndexPath: indexPath animated: NO];
   // Navigation logic may go here. Create and push another view controller.
   // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
   // [self.navigationController pushViewController:anotherViewController];
   // [anotherViewController release];
}


- (void)loadButtonPressed {
   [[Options sharedOptions] setLoadGameFile: [pgnFile filename]];
   [[Options sharedOptions] setLoadGameFileGameNumber: gameNumber];
   
   // HACK: This is ugly.  :-(
   [[(LoadFileListController *) [[[self navigationController] viewControllers]
                                   objectAtIndex: 0]
                                boardViewController]
      loadMenuDonePressedWithGame: [pgnFile pgnStringForGameNumber: gameNumber]];
}




@end
