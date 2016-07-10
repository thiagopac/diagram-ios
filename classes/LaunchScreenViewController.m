//
//  LaunchScreenViewController.m
//  Diagram
//
//  Created by Thiago Pires on 07/07/16.
//
//

#import "LaunchScreenViewController.h"
#import "UIImage+animatedGIF.h"

@interface LaunchScreenViewController ()

@end

@implementation LaunchScreenViewController
@synthesize imageView;

@synthesize contentView;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadView{
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    rootView = [[RootView alloc] initWithFrame: appRect];
    [rootView setBackgroundColor: [UIColor colorWithWhite:0.988 alpha:1.000]];
    
    contentView = [[UIView alloc] initWithFrame: appRect];
    [rootView addSubview: contentView];
    [self setView: rootView];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(appRect.size.width/2-150, appRect.size.height/2-84, 300, 169)];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"diagram-splash" withExtension:@"gif"];
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    
    [contentView addSubview:self.imageView];
    [contentView bringSubviewToFront:self.imageView];
}

@end
