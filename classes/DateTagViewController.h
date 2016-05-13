/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class GameDetailsTableController;

@interface DateTagViewController : UIViewController {
   GameDetailsTableController *gameDetailsController;
   UIDatePicker *datePicker;
}

- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc;
- (void)dateChanged:(UIDatePicker *)sender;

@end
