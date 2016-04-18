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

#import <UIKit/UIKit.h>

@class GameController;

@interface MoveListView : UIView {
   GameController *__weak gameController;
   UIWebView *webView;
}

- (void)setText:(NSString *)text;
- (void)setText:(NSString *)text scrollToPly:(int)ply;
- (void)scrollToPly:(int)ply;
- (void)setWebViewDelegate:(id)delegate;

@property (nonatomic, weak) GameController *gameController;

@end
