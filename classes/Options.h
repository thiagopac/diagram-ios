/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

enum GameMode {
   GAME_MODE_COMPUTER_BLACK,
   GAME_MODE_COMPUTER_WHITE,
   GAME_MODE_ANALYSE,
   GAME_MODE_TWO_PLAYER
};

enum GameLevel {
   LEVEL_GAME_IN_2,
   LEVEL_GAME_IN_2_PLUS_1,
   LEVEL_GAME_IN_5,
   LEVEL_GAME_IN_5_PLUS_2,
   LEVEL_GAME_IN_15,
   LEVEL_GAME_IN_15_PLUS_5,
   LEVEL_GAME_IN_30,
   LEVEL_GAME_IN_30_PLUS_5,
   LEVEL_1S_PER_MOVE,
   LEVEL_2S_PER_MOVE,
   LEVEL_5S_PER_MOVE,
   LEVEL_10S_PER_MOVE,
   LEVEL_30S_PER_MOVE
};

@interface Options : NSObject {
   UIColor *__strong darkSquareColor, *__strong lightSquareColor, *__strong highlightColor, *__strong selectedSquareColor;
   UIImage *__weak darkSquareImage, *__weak lightSquareImage;
   NSString *colorScheme;
   NSString *playStyle;
   NSString *bookVariety;
   BOOL bookVarietyWasChanged;
   NSString *pieceSet;
   BOOL moveSound;
   BOOL figurineNotation;
   BOOL showAnalysis;
   BOOL showBookMoves;
   BOOL showLegalMoves;
   BOOL permanentBrain;

   GameMode gameMode;
   BOOL gameModeWasChanged;
   GameLevel gameLevel;
   BOOL gameLevelWasChanged;

   BOOL playStyleWasChanged;
   BOOL strengthWasChanged;

   BOOL displayMoveGestureStepForwardHint;
   BOOL displayMoveGestureTakebackHint;

   int strength;

   BOOL showCoordinates;
   
   BOOL displayGameListSearchFieldHint;
   BOOL displayGamePreviewSwipingHint;   
}

@property (strong, nonatomic, readonly) UIColor *darkSquareColor;
@property (strong, nonatomic, readonly) UIColor *lightSquareColor;
@property (strong, nonatomic, readonly) UIColor *highlightColor;
@property (strong, nonatomic, readonly) UIColor *selectedSquareColor;
@property (weak, nonatomic, readonly) UIImage *darkSquareImage;
@property (weak, nonatomic, readonly) UIImage *lightSquareImage;
@property (nonatomic, strong) NSString *colorScheme;
@property (nonatomic, strong) NSString *playStyle;
@property (nonatomic, strong) NSString *bookVariety;
@property (nonatomic, readonly) BOOL bookVarietyWasChanged;
@property (nonatomic, strong) NSString *pieceSet;
@property (nonatomic, readwrite) BOOL moveSound;
@property (nonatomic, readwrite) BOOL figurineNotation;
@property (nonatomic, readwrite) BOOL showAnalysis;
@property (nonatomic, readwrite) BOOL showBookMoves;
@property (nonatomic, readwrite) BOOL showLegalMoves;
@property (nonatomic, readwrite) BOOL showCoordinates;
@property (nonatomic, readwrite) BOOL permanentBrain;
@property (nonatomic, assign) GameMode gameMode;
@property (nonatomic, assign) GameLevel gameLevel;
@property (nonatomic, readonly) BOOL gameModeWasChanged;
@property (nonatomic, readonly) BOOL gameLevelWasChanged;
@property (nonatomic, readonly) BOOL playStyleWasChanged;
@property (nonatomic, readonly) BOOL displayMoveGestureStepForwardHint;
@property (nonatomic, readonly) BOOL displayMoveGestureTakebackHint;
@property (nonatomic, assign) int strength;
@property (nonatomic, readonly) BOOL strengthWasChanged;
@property (nonatomic, readonly) BOOL displayGameListSearchFieldHint;
@property (nonatomic, readonly) BOOL displayGamePreviewSwipingHint;

+ (Options *)sharedOptions;

- (UIColor *)darkSquareColorForColorScheme:(NSString *)scheme;
- (UIColor *)lightSquareColorForColorScheme:(NSString *)scheme;
- (UIImage *)darkSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large;
- (UIImage *)lightSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large;
- (UIColor *)highlightColorForColorScheme:(NSString *)scheme;
- (UIColor *)selectedSquareColorForColorScheme:(NSString *)scheme;
- (UIColor *)brightHighlightColor;
- (void)updateColors;
- (BOOL)isFixedTimeLevel;
- (int)baseTime;
- (int)timeIncrement;
- (BOOL)maxStrength;

@end
