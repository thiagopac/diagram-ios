/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/


// CARACTERES UNICODE XADREZ "♔", "♕", "♖", "♗", "♘", "♙", "♚", "♛", "♜", "♝", "♞", "♟"

#import "AppDelegate.h"
#import "ECO.h"
#import "MoveListView.h"
#import "Options.h"
#import "SideToMoveController.h"

#include "../Chess/mersenne.h"
#include "../Chess/movepick.h"

using namespace Chess;

@implementation AppDelegate

@synthesize window, boardViewController, gameController, launchScreenViewController;


- (BOOL)application :(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    launchScreenViewController = [[LaunchScreenViewController alloc]init];
    [launchScreenViewController loadView];
    [window addSubview: [launchScreenViewController view]];
    [window setRootViewController: launchScreenViewController];
    [window makeKeyAndVisible];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [launchScreenViewController removeFromParentViewController];
        boardViewController = [[BoardViewController alloc] init];
        [boardViewController loadView];
        [window addSubview: [boardViewController view]];
        [window setRootViewController: boardViewController];
        [window makeKeyAndVisible];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        
        [self performSelectorInBackground: @selector(backgroundInit:)
                               withObject: nil];
    });


   return YES;
}


- (void)saveState {
   // Save the current game, level and game mode so we can recover it the next
   // time the program starts up:
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject: [[gameController game] pgnString]
                forKey: @"lastGame"];
   [defaults setInteger: ((int)[[Options sharedOptions] gameLevel] + 1)
                 forKey: @"gameLevel"];
   [defaults setInteger: ((int)[[Options sharedOptions] gameMode] + 1)
                 forKey: @"gameMode"];
   [defaults setBool: [gameController rotated]
              forKey: @"rotateBoard"];
   [defaults setInteger: [[gameController game] currentMoveIndex]
                 forKey: @"currentMoveIndex"];
   [defaults synchronize];
}



- (void)applicationWillTerminate:(UIApplication *)application {
   NSLog(@"AppDelegate applicationWillTerminate:");
   [self saveState];
}


- (void)applicationWillResignActive:(UIApplication *)application {
   NSLog(@"AppDelegate applicationWillResignActive:");
   [self saveState];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
   NSLog(@"AppDelegate willEnterForeground:");
//   [gameController checkPasteboard];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"url recieved: %@", url);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
    NSDictionary *dict = [self parseQueryString:[url query]];
    NSLog(@"query dict: %@", dict);
    
    
    /* Chess init */
    init_mersenne();
    init_direction_table();
    init_bitboards();
    Position::init_zobrist();
    Position::init_piece_square_tables();
    MovePicker::init_phase_table();
    
    // Make random number generation less deterministic, for book moves
    int i = abs(get_system_time() % 10000);
    for (int j = 0; j < i; j++)
    genrand_int32();
    
    [gameController loadPieceImages];
    
    [gameController showPiecesAnimate: NO];
    [boardViewController stopActivityIndicator];
    
    [boardViewController setGameController: gameController];
    [[boardViewController boardView] setGameController: gameController];
    [[boardViewController moveListView] setGameController: gameController];

    [gameController startNewGame];
    
    if (Position::is_valid_fen([dict[@"v"] UTF8String])) {
        [gameController gameFromFEN:dict[@"v"]];
    }else if(1 == 1){ //TO-DO criar teste válido para PGN
        [gameController gameFromPGNString:dict[@"v"] loadFromBeginning: NO];
    }
    
    [boardViewController hideLastMove];
    
   return YES;
}

- (void)backgroundInit:(id)anObject {
   @autoreleasepool {

      gameController =
         [[GameController alloc] initWithBoardView: [boardViewController boardView]
                                      moveListView: [boardViewController moveListView]];

      /* Chess init */
      init_mersenne();
      init_direction_table();
      init_bitboards();
      Position::init_zobrist();
      Position::init_piece_square_tables();
      MovePicker::init_phase_table();

      // Make random number generation less deterministic, for book moves
      int i = abs(get_system_time() % 10000);
      for (int j = 0; j < i; j++)
         genrand_int32();

      [gameController loadPieceImages];
      [self performSelectorOnMainThread: @selector(backgroundInitFinished:)
                             withObject: nil
                          waitUntilDone: NO];

   }
}


- (void)backgroundInitFinished:(id)anObject {
   
   [gameController showPiecesAnimate: NO];
   [boardViewController stopActivityIndicator];

   [boardViewController setGameController: gameController];
   [[boardViewController boardView] setGameController: gameController];
   [[boardViewController moveListView] setGameController: gameController];

   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

   NSString *lastGamePGNString = [defaults objectForKey: @"lastGame"];
    
   if (lastGamePGNString) {
      [gameController gameFromPGNString: lastGamePGNString
                      loadFromBeginning: NO];
      int currentMoveIndex = (int)[defaults integerForKey: @"currentMoveIndex"];
      [gameController jumpToPly: currentMoveIndex animate: NO];
   }
   else
      [gameController
         gameFromFEN: @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"];

   NSInteger gameLevel = [defaults integerForKey: @"gameLevel"];
   if (gameLevel) {
      [[Options sharedOptions] setGameLevel: (GameLevel)((int)gameLevel - 1)];
      [gameController setGameLevel: [[Options sharedOptions] gameLevel]];
   }

   if ([defaults objectForKey: @"rotateBoard"])
      [gameController rotateBoard: [defaults boolForKey: @"rotateBoard"] animate: NO];

   NSInteger gameMode = [defaults integerForKey: @"gameMode"];
   if (gameMode) {
      [[Options sharedOptions] setGameMode: (GameMode)(gameMode - 1)];
      [gameController setGameMode: [[Options sharedOptions] gameMode]];
   }

   //[gameController startEngine];
   [gameController showBookMoves];
   
//   [gameController checkPasteboard];
}


- (void)dealloc {
   NSLog(@"AppDelegate dealloc");
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end
