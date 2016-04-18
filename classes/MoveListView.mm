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

#import "GameController.h"
#import "MoveListView.h"


@implementation MoveListView

@synthesize gameController;

- (id)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame: frame]) {
      webView = [[UIWebView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];

      [[webView scrollView] setBounces: NO];
      NSString *cssFile = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?
         @"movelist-ipad.css" : @"movelist-iphone.css";
      [webView loadHTMLString:
                  [NSString stringWithFormat:
                               @"<html>\n"
                            "<head>\n"
                            "<meta charset=utf-8>\n"
                            "<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\">"
                            "<link rel=\"stylesheet\" href=\"%@\">\n"
                            "<script src=\"movelist.js\"></script>\n"
                            "</head>\n"
                            "<body>\n"
                            "</body>\n"
                            "</html>",
                            cssFile]
                      baseURL: [NSURL fileURLWithPath:
                                         [[NSBundle mainBundle] bundlePath]]];
      [self addSubview: webView];
   }
   return self;
}


- (void)setFrame:(CGRect)frame {
   [super setFrame: frame];
   [webView setFrame: CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
}


- (void)setText:(NSString *)text scrollToPly:(int)ply {
   [webView stringByEvaluatingJavaScriptFromString:
                        [NSString stringWithFormat: @""
                                  "document.body.innerHTML='%@';\n"
                                  "scrollToPly(%d); addMoveEventHandlers();",
                                  [text stringByReplacingOccurrencesOfString: @"'"
                                                                  withString: @"\\'"],
                                  ply]];
}


- (void)setText:(NSString *)text {
   [webView stringByEvaluatingJavaScriptFromString:
                        [NSString stringWithFormat:
                                     @"document.body.innerHTML='%@';",
                                  [text stringByReplacingOccurrencesOfString: @"'"
                                                                  withString: @"\\'"]]];
}


- (void)scrollToPly:(int)ply {
   [webView stringByEvaluatingJavaScriptFromString:
                        [NSString stringWithFormat: @"scrollToPly(%d);", ply]];
}


- (void)setWebViewDelegate:(id)delegate {
   [webView setDelegate: delegate];
}


@end
