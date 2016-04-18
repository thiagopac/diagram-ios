//
//  MTBAdvancedExampleViewController.h
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/10/14.
//
//

#import <UIKit/UIKit.h>
#import "RootView.h"

@class BoardViewController;

@interface ScanViewController : UIViewController{
    BoardViewController *__weak boardViewController;
    NSString *fen;
}

@property (weak, nonatomic, readonly) BoardViewController *boardViewController;

- (id)init;
- (id)initWithBoardViewController:(BoardViewController *)bvc;
- (UIView *)overlayForCodeString:(NSString *)codeString bounds:(CGRect)bounds valid:(BOOL)valid;

@end
