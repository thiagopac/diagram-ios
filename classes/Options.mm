/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "Options.h"
#import "ColorUtils.h"


@implementation Options

@synthesize darkSquareColor, lightSquareColor, highlightColor, selectedSquareColor;
@synthesize darkSquareImage, lightSquareImage;
@dynamic colorScheme, pieceSet, figurineNotation;
@dynamic playStyle, bookVariety, bookVarietyWasChanged, moveSound;
@dynamic showAnalysis, showBookMoves, showLegalMoves, permanentBrain, showCoordinates;
@dynamic gameMode, gameLevel, gameModeWasChanged, gameLevelWasChanged;
@dynamic displayMoveGestureStepForwardHint, displayMoveGestureTakebackHint;
@dynamic playStyleWasChanged, strength, strengthWasChanged;
@dynamic displayGameListSearchFieldHint, displayGamePreviewSwipingHint;

#define KEY_LOAD_GAME_FILE @"loadGameFile"
#define KEY_LOAD_GAME_FILE_NUMBER @"loadGameFileGameNumber"
#define KEY_SHOW_ANALYSIS @"showAnalysis2"
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
       
#pragma-mark ALTEREI A MOSTRAGEM DA ANÁLISE DE YES PARA NO
      if (![defaults objectForKey: KEY_SHOW_ANALYSIS]) {
         showAnalysis = NO;
         [defaults setBool: NO forKey: KEY_SHOW_ANALYSIS];
      }
      else
         showAnalysis = [defaults boolForKey: KEY_SHOW_ANALYSIS];

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
#pragma-mark ALTEREI A COR DAS CASAS ESCURAS NO TEMA CINZA
   return [UIColor colorWithRed:0.93 green:0.93 blue:0.95 alpha:1.0];
}


- (UIColor *)lightSquareColorForColorScheme:(NSString *)scheme {
#pragma-mark ALTEREI A COR DAS CASAS CLARAS NO TEMA CINZA
    return [UIColor whiteColor];

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
  return [UIColor colorWithRed:0.95 green:0.93 blue:0.29 alpha:1.0];

}


- (UIColor *)selectedSquareColorForColorScheme:(NSString *)scheme {
      return [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.4];
}


- (void)updateColors {
    darkSquareImage = nil;
    lightSquareImage = nil;
   
   BOOL large = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   
   darkSquareColor = [self darkSquareColorForColorScheme: colorScheme];
   lightSquareColor = [self lightSquareColorForColorScheme: colorScheme];
   highlightColor = [self highlightColorForColorScheme: colorScheme];
   selectedSquareColor = [self selectedSquareColorForColorScheme: colorScheme];
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
