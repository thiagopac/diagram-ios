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

#import "AboutController.h"
#import "PGN.h"


@implementation AboutController


- (id)init {
   if (self = [super init]) {
      //[self setContentSizeForViewInPopover: CGSizeMake(500.0f, 400.0f)];
      [self setPreferredContentSize: CGSizeMake(500.0f, 400.0f)];
   }   return self;
}

- (void)loadView {
   [super loadView];
   NSString *path = [[NSBundle mainBundle] pathForResource: @"about"
                                                    ofType: @"html"];
   NSURL *url = [[NSURL alloc] initFileURLWithPath: path];
   NSURLRequest *req = [NSURLRequest requestWithURL: url];
   UIWebView *webView =
      [[UIWebView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
   [webView setScalesPageToFit: YES];
   [webView loadRequest: req];
   [self setView: webView];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}




@end
