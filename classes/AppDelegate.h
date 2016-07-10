/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

#import "BoardViewController.h"
#import "GameController.h"
#import "LaunchScreenViewController.h"


@interface AppDelegate : NSObject <UIApplicationDelegate> {
   UIWindow *window;
    LaunchScreenViewController *launchScreenViewController;
   BoardViewController *boardViewController;
   GameController *gameController;
    UINavigationController *navigationController;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, readonly) LaunchScreenViewController *launchScreenViewController;
@property (nonatomic, readonly) BoardViewController *boardViewController;
@property (nonatomic, readonly) GameController *gameController;

- (void)backgroundInit:(id)anObject;
- (void)backgroundInitFinished:(id)anObject;

@end

