/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "Options.h"
#import "OptionsViewController.h"
#import "StrengthOptionController.h"


@implementation StrengthOptionController

- (id)initWithParentViewController:(OptionsViewController *)ovc {
   if (self = [super init]) {
      parentController = ovc;
   }
   return self;
}


- (void)loadView {
   [super loadView];

   UIView *contentView;
   CGRect r = [[UIScreen mainScreen] applicationFrame];

   [self setTitle: @"Strength"];

   contentView = [[UIView alloc] initWithFrame: r];
   [contentView setBackgroundColor: [UIColor whiteColor]];
   [self setView: contentView];

   UIPickerView *picker = [[UIPickerView alloc]
                            initWithFrame: CGRectMake(0.0f, 64.0f, 320.0f, 220.0f)];
   [picker setDelegate: self];
   [picker setDataSource: self];
   [picker setShowsSelectionIndicator: YES];
   [picker selectRow: 20 - [[Options sharedOptions] strength]
         inComponent: 0
            animated: NO];
   [contentView addSubview: picker];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
   return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
   return 21;
}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
   return [NSString stringWithFormat: @"%d", 20 - (int)row];
}


- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
   [[Options sharedOptions] setStrength: 20 - (int)row];
   NSLog(@"new strength: %d", [[Options sharedOptions] strength]);
   [parentController updateTableCells];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}



@end
