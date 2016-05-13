/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
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
