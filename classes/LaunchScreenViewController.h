//
//  LaunchScreenViewController.h
//  Diagram
//
//  Created by Thiago Pires on 07/07/16.
//
//

#import <UIKit/UIKit.h>
#import "RootView.h"

@interface LaunchScreenViewController : UIViewController{
    RootView *rootView;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
