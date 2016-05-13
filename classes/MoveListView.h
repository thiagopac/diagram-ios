/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
