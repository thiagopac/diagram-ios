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


// CARACTERES UNICODE XADREZ "♔", "♕", "♖", "♗", "♘", "♙", "♚", "♛", "♜", "♝", "♞", "♟"

#import "AppDelegate.h"
#import "ECO.h"
#import "MoveListView.h"
#import "Options.h"

#include "../Chess/mersenne.h"
#include "../Chess/movepick.h"

using namespace Chess;

@implementation AppDelegate

@synthesize window, viewController, gameController;


- (BOOL)application :(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

   viewController = [[BoardViewController alloc] init];
   [viewController loadView];
   [window addSubview: [viewController view]];
   [window setRootViewController: viewController];
   [window makeKeyAndVisible];

   [[UIApplication sharedApplication] setIdleTimerDisabled: YES];

   [self performSelectorInBackground: @selector(backgroundInit:)
                          withObject: nil];
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
   [defaults setInteger: [[[gameController game] clock] whiteRemainingTime] + 1
                 forKey: @"whiteRemainingTime"];
   [defaults setInteger: [[[gameController game] clock] blackRemainingTime] + 1
                 forKey: @"blackRemainingTime"];
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
   
    NSString *homeDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
   NSString *fileName = [url.absoluteString componentsSeparatedByString:@"/"].lastObject;
   NSURL *url2 = [NSURL fileURLWithPath: [homeDir stringByAppendingPathComponent: fileName]];
   [[NSFileManager defaultManager] moveItemAtURL:url toURL:url2 error:NULL];

   [[Options sharedOptions] setLoadGameFile: [url2 absoluteString]];
   [[Options sharedOptions] setLoadGameFileGameNumber:NSIntegerMax]; // HACK
   [viewController showLoadGameMenu];
   return YES;
}

- (void)backgroundInit:(id)anObject {
   @autoreleasepool {

      gameController =
         [[GameController alloc] initWithBoardView: [viewController boardView]
                                      moveListView: [viewController moveListView]
                                      analysisView: [viewController analysisView]
                                     bookMovesView: [viewController bookMovesView]
                                    whiteClockView: [viewController whiteClockView]
                                    blackClockView: [viewController blackClockView]
                                   searchStatsView: [viewController searchStatsView]];

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
   [viewController stopActivityIndicator];

   [viewController setGameController: gameController];
   [[viewController boardView] setGameController: gameController];
   [[viewController moveListView] setGameController: gameController];

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

   NSInteger whiteRemainingTime = [defaults integerForKey: @"whiteRemainingTime"];
   NSInteger blackRemainingTime = [defaults integerForKey: @"blackRemainingTime"];
   ChessClock *clock = [[gameController game] clock];
   if (whiteRemainingTime)
      [clock addTimeForWhite: ((int)whiteRemainingTime - [clock whiteRemainingTime])];
   if (blackRemainingTime)
      [clock addTimeForBlack: ((int)blackRemainingTime - [clock blackRemainingTime])];

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


@end
