/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */


#import "Options.h"
#import "OptionsViewController.h"
#import "PiecePreview.h"
#import "SelectPieceSetController.h"

@interface SelectPieceSetController ()

@end

@implementation SelectPieceSetController


- (id)initWithParentViewController:(OptionsViewController *)ovc {
   if (self = [super initWithStyle: UITableViewStylePlain]) {
      optionsViewController = ovc;
      contents = [NSArray arrayWithObjects: @"Alpha", @"Merida", @"Leipzig",
                   @"USCF", @"Russian", @"Modern", @"Berlin", @"Cheq", @"Maya",
                   @"Invisible", nil];
      [self setTitle: @"Piece set"];
      checkedRow = [contents indexOfObject: [[Options sharedOptions]
                                             valueForKey: @"pieceSet"]];
   }
   return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [contents count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   float sz = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
   40.0f : [[UIScreen mainScreen] applicationFrame].size.width / 8.0f;
   return 2 * sz + 26.0;
   //return 106.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   NSString *name = [contents objectAtIndex: row];
   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: name];
   PiecePreview *preview;
   UILabel *smallLabel;
   if (cell == nil) {
      float sz = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
      40.0f : [[UIScreen mainScreen] applicationFrame].size.width / 8.0f;
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: name];
      preview = [[PiecePreview alloc] initWithFrame: CGRectMake(16, 5, 6*sz, 2*sz)
                                        colorScheme: [[Options sharedOptions] colorScheme]
                                           pieceSet: [contents objectAtIndex: row]];
      [[cell contentView] addSubview: preview];
      smallLabel = [[UILabel alloc] initWithFrame: CGRectMake(16, 2*sz + 7, 200, 14)];
      [smallLabel setFont: [UIFont systemFontOfSize: 13.0]];
      [smallLabel setText: name];
      [[cell contentView] addSubview: smallLabel];
   }
   [[cell textLabel] setText: name];
   [[cell textLabel] setTextColor: [UIColor clearColor]];
   if ([[[cell textLabel] text] isEqualToString: [[Options sharedOptions]
                                                  valueForKey: @"pieceSet"]]) {
      [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
      checkedRow = row;
   }
   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1];
   if (row != checkedRow) {
      [[Options sharedOptions] setValue: [[[tableView cellForRowAtIndexPath: indexPath]
                                           textLabel] text]
                                 forKey: @"pieceSet"];
      [[tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: checkedRow
                                                            inSection: 0]]
       setAccessoryType: UITableViewCellAccessoryNone];
      [[tableView cellForRowAtIndexPath: indexPath]
       setAccessoryType: UITableViewCellAccessoryCheckmark ];
      checkedRow = row;
      [optionsViewController updateTableCells];
   }
   [[self navigationController] popViewControllerAnimated: YES];
}


- (void)deselect:(UITableView *)tableView {
   [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                            animated: YES];
}


@end
