/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
