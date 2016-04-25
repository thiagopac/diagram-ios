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

#import "Options.h"
#import "ColorUtils.h"


@implementation Options

@synthesize darkSquareColor, lightSquareColor, highlightColor, selectedSquareColor, arrowColor, arrowOutlineColor;
@synthesize darkSquareImage, lightSquareImage;
@dynamic colorScheme, pieceSet, figurineNotation;
@dynamic playStyle, bookVariety, bookVarietyWasChanged, moveSound;
@dynamic showAnalysis, showArrow, showBookMoves, showLegalMoves, permanentBrain, showCoordinates;
@dynamic gameMode, gameLevel, gameModeWasChanged, gameLevelWasChanged;
@dynamic saveGameFile, emailAddress, fullUserName;
@dynamic displayMoveGestureStepForwardHint, displayMoveGestureTakebackHint;
@dynamic playStyleWasChanged, strength, strengthWasChanged;
@dynamic loadGameFile, loadGameFileGameNumber;
@dynamic displayGameListSearchFieldHint, displayGamePreviewSwipingHint;

#define KEY_LOAD_GAME_FILE @"loadGameFile"
#define KEY_LOAD_GAME_FILE_NUMBER @"loadGameFileGameNumber"
#define KEY_SHOW_ANALYSIS @"showAnalysis2"
#define KEY_SHOW_ARROW @"showArrow2"
#define KEY_SHOW_BOOK_MOVES @"showBookMoves2"
#define KEY_SHOW_LEGAL_MOVES @"showLegalMoves2"
#define KEY_SHOW_COORDINATES @"showCoordinates2"
#define KEY_PERMANENT_BRAIN @"permanentBrain2"
#define KEY_PIECE_SET @"pieceSet6"
#define KEY_PLAY_STYLE @"playStyle3"
#define KEY_BOOK_VARIETY @"bookVariety2"
#define KEY_MOVE_SOUND @"moveSound"
#define KEY_FIGURINE_NOTATION @"figurineNotation2"
#define KEY_COLOR_SCHEME @"colorScheme5"
#define KEY_SAVE_GAME_FILE @"saveGameFile2"
#define KEY_EMAIL_ADDRESS @"emailAddress2"
#define KEY_FULL_USER_NAME @"fullUserName2"
#define KEY_STRENGTH @"strength"
#define KEY_DISPLAY_MOVE_GESTURE_TAKEBACK_HINT @"displayMoveGestureTakebackHint3"
#define KEY_DISPLAY_MOVE_GESTURE_STEP_FORWARD_HINT @"displayMoveGestureStepForwardHint3"
#define KEY_DISPLAY_GAME_LIST_SEARCH_FIELD_HINT @"displayGameListSearchFieldHint2"
#define KEY_DISPLAY_GAME_PREVIEW_SWIPING_HINT @"displayGamePreviewSwipingHint2"


- (id)init {
   if (self = [super init]) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

      loadGameFile = [defaults objectForKey: KEY_LOAD_GAME_FILE];
      if (!loadGameFile) {
         loadGameFile = @"";
      }
      loadGameFileGameNumber = (int)[defaults integerForKey: KEY_LOAD_GAME_FILE_NUMBER];
      if (!loadGameFileGameNumber) {
         loadGameFileGameNumber = 0;
      }
       
#pragma-mark ALTEREI A MOSTRAGEM DA ANÁLISE DE YES PARA NO
      if (![defaults objectForKey: KEY_SHOW_ANALYSIS]) {
         showAnalysis = NO;
         [defaults setBool: NO forKey: KEY_SHOW_ANALYSIS];
      }
      else
         showAnalysis = [defaults boolForKey: KEY_SHOW_ANALYSIS];

#pragma-mark ALTEREI A MOSTRAGEM DAS SETAS DE DICAS DE YES PARA NO
      if (![defaults objectForKey:KEY_SHOW_ARROW]) {
         showArrow = NO;
         [defaults setBool: NO forKey:KEY_SHOW_ARROW];
      } else {
         showArrow = [defaults boolForKey:KEY_SHOW_ARROW];
      }

#pragma-mark ALTEREI A MOSTRAGEM DOS BOOK MOVES DE YES PARA NO
      if (![defaults objectForKey: KEY_SHOW_BOOK_MOVES]) {
         showBookMoves = NO;
         [defaults setBool: NO forKey: KEY_SHOW_BOOK_MOVES];
      }
      else
         showBookMoves = [defaults boolForKey: KEY_SHOW_BOOK_MOVES];

      if (![defaults objectForKey: KEY_SHOW_LEGAL_MOVES]) {
         showLegalMoves = YES;
         [defaults setBool: YES forKey: KEY_SHOW_LEGAL_MOVES];
      }
      else
         showLegalMoves = [defaults boolForKey: KEY_SHOW_LEGAL_MOVES];

      if (![defaults objectForKey: KEY_SHOW_COORDINATES]) {
         showCoordinates = NO;
         [defaults setBool: NO forKey: KEY_SHOW_COORDINATES];
      }
      else
         showCoordinates = [defaults boolForKey: KEY_SHOW_COORDINATES];

      if (![defaults objectForKey: KEY_PERMANENT_BRAIN]) {
         permanentBrain = NO;
         [defaults setBool: NO forKey: KEY_PERMANENT_BRAIN];
      }
      else
         permanentBrain = [defaults boolForKey: KEY_PERMANENT_BRAIN];

#pragma-mark ALTEREI O TEMA DE PEÇAS PADRÃO DE Merida PARA Alpha
      pieceSet = [defaults objectForKey: KEY_PIECE_SET];
      if (!pieceSet) {
         pieceSet = @"Alpha";
         [defaults setObject: @"Alpha" forKey: KEY_PIECE_SET];
      }

      playStyle = [defaults objectForKey: KEY_PLAY_STYLE];
      if (!playStyle) {
         playStyle = @"Active";
         [defaults setObject: @"Active" forKey: KEY_PLAY_STYLE];
      }

      bookVariety = [defaults objectForKey: KEY_BOOK_VARIETY];
      if (!bookVariety) {
         bookVariety = @"Medium";
         [defaults setObject: @"Medium" forKey: KEY_BOOK_VARIETY];
      }

#pragma-mark ALTEREI A OPÇÃO DE SOM AO MOVER PEÇAS DE YES PARA NO
      if (![defaults objectForKey: KEY_MOVE_SOUND]) {
         moveSound = NO;
         [defaults setBool: NO forKey: KEY_MOVE_SOUND];
      }
      else
         moveSound = [defaults boolForKey: KEY_MOVE_SOUND];

      if (![defaults objectForKey: KEY_FIGURINE_NOTATION]) {
         figurineNotation = NO;
         [defaults setBool: NO forKey: KEY_FIGURINE_NOTATION];
      }
      else
         figurineNotation = [defaults boolForKey: KEY_FIGURINE_NOTATION];

      colorScheme = [defaults objectForKey: KEY_COLOR_SCHEME];
      if (!colorScheme) {
#pragma-mark ALTEREI A COR DO TEMA PADRÃO DE AZUL PARA CINZA
         colorScheme = @"Gray";
         [defaults setObject: @"Gray" forKey: KEY_COLOR_SCHEME];
      }
      //darkSquareColor = lightSquareColor = highlightColor = selectedSquareColor = nil;
      [self updateColors];

       
#pragma-mark ALTEREI TEMPO PADRÃO DE JOGO DE LEVEL_GAME_IN_5 PARA LEVEL_2S_PER_MOVE
       
      gameMode = GAME_MODE_COMPUTER_BLACK;
      gameLevel = LEVEL_2S_PER_MOVE;
      gameModeWasChanged = NO;
      gameLevelWasChanged = NO;
      playStyleWasChanged = NO;
      strengthWasChanged = NO;

      saveGameFile = [defaults objectForKey: KEY_SAVE_GAME_FILE];
      if (!saveGameFile) {
         saveGameFile = @"My games.pgn";
         [defaults setObject: @"My Games.pgn" forKey: KEY_SAVE_GAME_FILE];
      }

      emailAddress = [defaults objectForKey: KEY_EMAIL_ADDRESS];
      if (!emailAddress) {
         emailAddress = @"";
         [defaults setObject: @"" forKey: KEY_EMAIL_ADDRESS];
      }

      fullUserName = [defaults objectForKey: KEY_FULL_USER_NAME];
      if (!fullUserName) {
         fullUserName = @"Me";
         [defaults setObject: @"Me" forKey: KEY_FULL_USER_NAME];
      }

      strength = (int)[defaults integerForKey: KEY_STRENGTH];
      if (!strength) {
         strength = 20;
         [defaults setInteger: 20 forKey: KEY_STRENGTH];
      }

      NSString *tmp = [defaults objectForKey:KEY_DISPLAY_MOVE_GESTURE_TAKEBACK_HINT];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: KEY_DISPLAY_MOVE_GESTURE_TAKEBACK_HINT];
         displayMoveGestureTakebackHint = YES;
      }
      else displayMoveGestureTakebackHint = [tmp isEqualToString: @"YES"];
       
      tmp = [defaults objectForKey: KEY_DISPLAY_MOVE_GESTURE_STEP_FORWARD_HINT];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: KEY_DISPLAY_MOVE_GESTURE_STEP_FORWARD_HINT];
         displayMoveGestureStepForwardHint = YES;
      }
      else displayMoveGestureStepForwardHint = [tmp isEqualToString: @"YES"];

      tmp = [defaults objectForKey: KEY_DISPLAY_GAME_LIST_SEARCH_FIELD_HINT];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: KEY_DISPLAY_GAME_LIST_SEARCH_FIELD_HINT];
         displayGameListSearchFieldHint = YES;
      }
      else displayGameListSearchFieldHint = [tmp isEqualToString: @"YES"];
      
      tmp = [defaults objectForKey: KEY_DISPLAY_GAME_PREVIEW_SWIPING_HINT];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: KEY_DISPLAY_GAME_PREVIEW_SWIPING_HINT];
         displayGamePreviewSwipingHint = YES;
      }
      else displayGamePreviewSwipingHint = [tmp isEqualToString: @"YES"];

      [defaults synchronize];
   }
   return self;
}


- (UIColor *)darkSquareColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Blue"])
      // return [UIColor colorWithRed: 0.2 green: 0.4 blue: 0.7 alpha: 1.0];
      return [UIColor colorWithRed: 0.24 green: 0.48 blue: 0.84 alpha: 1.0];
   else if ([scheme isEqualToString: @"Gray"])
//      return [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1.0];
#pragma-mark ALTEREI A COR DAS CASAS ESCURAS NO TEMA CINZA
       return [UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0];
   else if ([scheme isEqualToString: @"Red"])
      return [UIColor colorWithRed: 0.6 green: 0.28 blue: 0.28 alpha: 1.0];
   else if ([scheme isEqualToString: @"Green"])
      //return [UIColor colorWithRed: 0.22 green: 0.31 blue: 0.22 alpha: 1.0];
      return [UIColor colorWithRed: 0.26 green: 0.37 blue: 0.26 alpha: 1.0];
   else // Default, brown
      return [UIColor colorWithRed: 0.74 green: 0.49 blue: 0.32 alpha: 1.0];
}


- (UIColor *)lightSquareColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Blue"])
      // return [UIColor colorWithRed: 0.69 green: 0.78 blue: 1.0 alpha: 1.0];
      return [UIColor colorWithRed: 0.7 green: 0.8 blue: 1.0 alpha: 1.0];
   else if ([scheme isEqualToString: @"Gray"])
#pragma-mark ALTEREI A COR DAS CASAS CLARAS NO TEMA CINZA
//      return [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1.0];
//    return [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1.0];
    return [UIColor whiteColor];
   else if ([scheme isEqualToString: @"Red"])
      return [UIColor colorWithRed: 1.0 green: 0.8 blue: 0.8 alpha: 1.0];
   else if ([scheme isEqualToString: @"Green"])
      // return [UIColor colorWithRed: 0.47 green: 0.59 blue: 0.43 alpha: 1.0];
      return [UIColor colorWithRed: 0.56 green: 0.71 blue: 0.52 alpha: 1.0];
   else // Default, brown
      return [UIColor colorWithRed: 0.96 green: 0.84 blue: 0.66 alpha: 1.0];
}


- (UIImage *)darkSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large {
   if (large) {
      if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"DarkWood96.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"DarkNewspaper96.png"];
      else
         return nil;
   } else {
      if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"DarkWood.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"DarkNewspaper.png"];
      else
         return nil;
   }
}


- (UIImage *)lightSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large {
   if (large) {
      if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"LightWood96.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"LightNewspaper96.png"];
      else
         return nil;
   } else {
      if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"LightWood.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"LightNewspaper.png"];
      else
         return nil;
   }
}


- (UIColor *)highlightColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Green"]) {
      return [UIColor colorWithRed:0.6 green:0.0 blue:0.3 alpha:1.0];
   } else if ([scheme isEqualToString: @"Blue"]) {
      return [UIColor orangeColor];
   } else if ([scheme isEqualToString: @"Gray"]) {
      return [UIColor colorWithRed:0.45 green:0.63 blue:0.55 alpha:1.0];
   } else {
      return [[self darkSquareColorForColorScheme:scheme] complementaryColor];
   }
}


- (UIColor *)selectedSquareColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Newspaper"])
      return [UIColor colorWithRed: 0.2 green: 0.6 blue: 1.0 alpha: 0.4];
   else
       
#pragma COR DA VIEW REDONDA QUE APARECE AO ESCOLHER CASA PARA ONDE IRÁ MOVER A PEÇA
      return [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.4];
}


- (UIColor *)arrowColorForColorScheme:(NSString *)scheme {
   return [[self highlightColorForColorScheme:scheme] colorWithAlphaComponent:0.5f];
}


- (UIColor *)arrowOutlineColorForColorScheme:(NSString *)scheme {
   return [[[self highlightColorForColorScheme:scheme]
         interpolateTowardsColor:[UIColor blackColor] atPoint:0.5f]
         colorWithAlphaComponent:0.8f];
}


- (void)updateColors {
    darkSquareImage = nil;
    lightSquareImage = nil;
   
   BOOL large = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   
   darkSquareColor = [self darkSquareColorForColorScheme: colorScheme];
   lightSquareColor = [self lightSquareColorForColorScheme: colorScheme];
   highlightColor = [self highlightColorForColorScheme: colorScheme];
   selectedSquareColor = [self selectedSquareColorForColorScheme: colorScheme];
   arrowColor = [self arrowColorForColorScheme: colorScheme];
   arrowOutlineColor = [self arrowOutlineColorForColorScheme:colorScheme];
   darkSquareImage = [self darkSquareImageForColorScheme: colorScheme
                                                    large: large];
   lightSquareImage = [self lightSquareImageForColorScheme: colorScheme
                                                      large: large];

   // Post a notification about the new colors, in order to make the board
   // update itself:
   [[NSNotificationCenter defaultCenter]
    postNotificationName: @"StockfishColorSchemeChanged"
    object: self];

   return;
}


- (NSString *)colorScheme {
   return colorScheme;
}


- (void)setColorScheme:(NSString *)newColorScheme {
   colorScheme = newColorScheme;
   [[NSUserDefaults standardUserDefaults] setObject: newColorScheme
                                             forKey: KEY_COLOR_SCHEME];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter]
      postNotificationName: @"StockfishPieceSetChanged"
                    object: self];
   [self updateColors];
}


- (BOOL)figurineNotation {
   return figurineNotation;
}


- (UIColor *)brightHighlightColor {
    
//    return [highlightColor interpolateTowardsColor:[UIColor redColor] atPoint:0.1f];
#pragma-mark ALTEREI A COR DAS VIEWS QUE APARECEM NAS CASAS DE MOVIMENTOS POSSÍVEIS DE CADA PEÇA
    return [UIColor colorWithRed:0.40 green:0.49 blue:0.57 alpha:1.0];
}

- (void)setFigurineNotation:(BOOL)newValue {
   figurineNotation = newValue;
   [[NSUserDefaults standardUserDefaults] setBool: figurineNotation
                                           forKey: KEY_FIGURINE_NOTATION];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)moveSound {
   return moveSound;
}


- (void)setMoveSound:(BOOL)newValue {
   moveSound = newValue;
   [[NSUserDefaults standardUserDefaults] setBool: moveSound
                                           forKey: KEY_MOVE_SOUND];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)pieceSet {
   return pieceSet;
}


- (void)setPieceSet:(NSString *)newPieceSet {
   pieceSet = newPieceSet;
   [[NSUserDefaults standardUserDefaults] setObject: newPieceSet
                                             forKey: KEY_PIECE_SET];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter]
      postNotificationName: @"StockfishPieceSetChanged"
                    object: self];
}


- (NSString *)playStyle {
   return playStyle;
}


- (void)setPlayStyle:(NSString *)newPlayStyle {
   playStyle = newPlayStyle;
   playStyleWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setObject: newPlayStyle
                                             forKey: KEY_PLAY_STYLE];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)playStyleWasChanged {
   BOOL result = playStyleWasChanged;
   playStyleWasChanged = NO;
   return result;
}


- (NSString *)bookVariety {
   return bookVariety;
}


- (void)setBookVariety:(NSString *)newBookVariety {
   bookVariety = newBookVariety;
   bookVarietyWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setObject: newBookVariety
                                             forKey: KEY_BOOK_VARIETY];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)bookVarietyWasChanged {
   BOOL result = bookVarietyWasChanged;
   bookVarietyWasChanged = NO;
   return result;
}


- (BOOL)showAnalysis {
   return showAnalysis;
}


- (void)setShowAnalysis:(BOOL)shouldShowAnalysis {
   showAnalysis = shouldShowAnalysis;
   [[NSUserDefaults standardUserDefaults] setBool: showAnalysis
                                           forKey: KEY_SHOW_ANALYSIS];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showArrow {
   return showArrow;
}


- (void)setShowArrow:(BOOL)shouldShowArrow {
   showArrow = shouldShowArrow;
   [[NSUserDefaults standardUserDefaults] setBool:showArrow
                                           forKey:KEY_SHOW_ARROW];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showBookMoves {
   return showBookMoves;
}


- (void)setShowBookMoves:(BOOL)shouldShowBookMoves {
   showBookMoves = shouldShowBookMoves;
   [[NSUserDefaults standardUserDefaults] setBool: showBookMoves
                                           forKey: KEY_SHOW_BOOK_MOVES];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showLegalMoves {
   return showLegalMoves;
}


- (void)setShowLegalMoves:(BOOL)shouldShowLegalMoves {
   showLegalMoves = shouldShowLegalMoves;
   [[NSUserDefaults standardUserDefaults] setBool: showLegalMoves
                                           forKey: KEY_SHOW_LEGAL_MOVES];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showCoordinates {
   return showCoordinates;
}


- (void)setShowCoordinates:(BOOL)shouldShowCoordinates {
   showCoordinates = shouldShowCoordinates;
   [[NSUserDefaults standardUserDefaults] setBool: showCoordinates
                                           forKey: KEY_SHOW_COORDINATES];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter]
      postNotificationName: @"StockfishShowCoordinatesChanged"
                    object: self];
}


- (BOOL)permanentBrain {
   return permanentBrain;
}


- (void)setPermanentBrain:(BOOL)shouldUsePermanentBrain {
   permanentBrain = shouldUsePermanentBrain;
   [[NSUserDefaults standardUserDefaults] setBool: permanentBrain
                                           forKey: KEY_PERMANENT_BRAIN];
   [[NSUserDefaults standardUserDefaults] synchronize];
}



+ (Options *)sharedOptions {
   static Options *o = nil;
   if (o == nil) {
      o = [[Options alloc] init];
   }
   return o;
}


- (GameLevel)gameLevel {
   return gameLevel;
}


- (void)setGameLevel:(GameLevel)newGameLevel {
   gameLevel = newGameLevel;
   gameLevelWasChanged = YES;
}

- (GameMode)gameMode {
   return gameMode;
}


- (void)setGameMode:(GameMode)newGameMode {
   gameMode = newGameMode;
   gameModeWasChanged = YES;
}


- (BOOL)gameModeWasChanged {
   BOOL result = gameModeWasChanged;
   gameModeWasChanged = NO;
   return result;
}


- (BOOL)gameLevelWasChanged {
   BOOL result = gameLevelWasChanged;
   gameLevelWasChanged = NO;
   return result;
}


- (NSString *)saveGameFile {
   return saveGameFile;
}


- (void)setSaveGameFile:(NSString *)newFileName {
   saveGameFile = newFileName;
   [[NSUserDefaults standardUserDefaults] setObject: saveGameFile
                                             forKey: KEY_SAVE_GAME_FILE];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)emailAddress {
   return emailAddress;
}


- (void)setEmailAddress:(NSString *)newEmailAddress {
   emailAddress = newEmailAddress;
   [[NSUserDefaults standardUserDefaults] setObject: emailAddress
                                             forKey: KEY_EMAIL_ADDRESS];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)fullUserName {
   return fullUserName;
}


- (void)setFullUserName:(NSString *)name {
   fullUserName = name;
   [[NSUserDefaults standardUserDefaults] setObject: fullUserName
                                             forKey: KEY_FULL_USER_NAME];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (int)strength {
   return strength;
}

- (BOOL)maxStrength {
   return strength == 20;
}

- (void)setStrength:(int)newStrength {
   strength = newStrength;
   strengthWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setInteger: newStrength
                                              forKey: KEY_STRENGTH];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)strengthWasChanged {
   BOOL result = strengthWasChanged;
   strengthWasChanged = NO;
   return result;
}


- (NSString *)loadGameFile {
   return loadGameFile;
}

- (void)setLoadGameFile:(NSString *)lgf {
   loadGameFile = lgf;
   [[NSUserDefaults standardUserDefaults] setObject: loadGameFile
                                             forKey: KEY_LOAD_GAME_FILE];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)loadGameFileGameNumber {
   return loadGameFileGameNumber;
}

- (void)setLoadGameFileGameNumber:(int)lgfgn {
   loadGameFileGameNumber = lgfgn;
   [[NSUserDefaults standardUserDefaults] setInteger: loadGameFileGameNumber
                                              forKey: KEY_LOAD_GAME_FILE_NUMBER];
}

- (BOOL)displayMoveGestureTakebackHint {
   BOOL tmp = displayMoveGestureTakebackHint;
   displayMoveGestureTakebackHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: KEY_DISPLAY_MOVE_GESTURE_TAKEBACK_HINT];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayMoveGestureStepForwardHint {
   BOOL tmp = displayMoveGestureStepForwardHint;
   displayMoveGestureStepForwardHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: KEY_DISPLAY_MOVE_GESTURE_STEP_FORWARD_HINT];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayGameListSearchFieldHint {
   BOOL tmp = displayGameListSearchFieldHint;
   displayGameListSearchFieldHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: KEY_DISPLAY_GAME_LIST_SEARCH_FIELD_HINT];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayGamePreviewSwipingHint {
   BOOL tmp = displayGamePreviewSwipingHint;
   displayGamePreviewSwipingHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: KEY_DISPLAY_GAME_PREVIEW_SWIPING_HINT];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


static const BOOL FixedTime[13] = {
   NO, NO, NO, NO, NO, NO, NO, NO, YES, YES, YES, YES, YES
};
static const int LevelTime[13] = {
   2, 2, 5, 5, 15, 15, 30, 30, 0, 0, 0, 0, 0
};
static const int LevelIncr[13] = {
   0, 1, 0, 2, 0, 5, 0, 5, 1, 2, 5, 10, 30
};

- (BOOL)isFixedTimeLevel {
   assert(gameLevel < 13);
   return FixedTime[gameLevel];
}

- (int)baseTime {
   assert(gameLevel < 13);
   return LevelTime[gameLevel] * 60000;
}

- (int)timeIncrement {
   assert(gameLevel < 13);
   return LevelIncr[gameLevel] * 1000;
}


@end
