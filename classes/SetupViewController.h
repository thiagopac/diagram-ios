/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class BoardViewController;
@class ScanViewController;
@class SetupBoardView;

@interface SetupViewController : UIViewController {
   BoardViewController *__weak boardViewController;
   ScanViewController *__weak scanViewController;
    
   SetupBoardView *boardView;
   UISegmentedControl *menu;
   NSString *fen;
}

@property (weak, nonatomic, readonly) BoardViewController *boardViewController;
@property (weak, nonatomic, readonly) ScanViewController *scanViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc
                              fen:(NSString *)aFen;
- (id)initWithScanViewController:(ScanViewController *)svc
                              fen:(NSString *)aFen;
- (void)buttonPressed:(id)sender;
- (void)disableDoneButton;
- (void)enableDoneButton;

@end
