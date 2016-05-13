/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "Game.h"
#import "GameDetailsTableController.h"
#import "DateTagViewController.h"


@implementation DateTagViewController


- (id)initWithGameDetailsController:(GameDetailsTableController *)gdtc {
   if (self = [super init]) {
      gameDetailsController = gdtc;
      [self setPreferredContentSize: [gdtc preferredContentSize]];
   }
   return self;
}


- (void)loadView {
   [super loadView];
   [[self navigationItem] setTitle: @"Date"];

   UIView *contentView =
      [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
   [contentView setBackgroundColor: [UIColor whiteColor]];
   [self setView: contentView];

   datePicker = [[UIDatePicker alloc] initWithFrame:
                                         CGRectMake(0.0f, 20.0f + 64.0f, 320.0f, 216.0f)];
   [datePicker setDatePickerMode: UIDatePickerModeDate];
   [datePicker addTarget: self action: @selector(dateChanged:)
        forControlEvents: UIControlEventValueChanged];
   [contentView addSubview: datePicker];
}


- (void)dateChanged:(UIDatePicker *)sender {
   // TODO: Correct date format.
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
   [[gameDetailsController game]
      setDate: [dateFormatter stringFromDate: [sender date]]];
   [gameDetailsController updateTableCells];
   NSLog(@"%@", [[gameDetailsController game] date]);
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
[super viewDidLoad];
}
*/

 /*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}




@end
