/*
 Diagram
 Created by Thiago Castro
 Copyright (c) 2016 Thiago Castro. All rights reserved.
 */

#import "Options.h"
#import "OptionsViewController.h"
#import "PiecePreview.h"
#import "SelectColorSchemeController.h"

@interface SelectColorSchemeController ()

@end

@implementation SelectColorSchemeController

- (id)initWithParentViewController:(OptionsViewController *)ovc {
   if (self = [super initWithStyle: UITableViewStylePlain]) {
      optionsViewController = ovc;
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
         contents = [NSArray arrayWithObjects: @"Green", @"Blue", @"Newspaper",
                      @"Brown", @"Gray", @"Red", @"Wood", nil];
      else
         // The "Newspaper" color scheme looks ugly on the iPad; disable it!
         contents = [NSArray arrayWithObjects: @"Green", @"Blue",
                      @"Brown", @"Gray", @"Red", @"Wood", nil];
      [self setTitle: @"Color scheme"];
      checkedRow = [contents indexOfObject: [[Options sharedOptions]
                                             valueForKey: @"colorScheme"]];
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
                                        colorScheme: [contents objectAtIndex: row]
                                           pieceSet: [[Options sharedOptions] pieceSet]];
      [[cell contentView] addSubview: preview];
      smallLabel = [[UILabel alloc] initWithFrame: CGRectMake(16, 2*sz+7, 200, 14)];
      [smallLabel setFont: [UIFont systemFontOfSize: 13.0]];
      [smallLabel setText: name];
      [[cell contentView] addSubview: smallLabel];
   }
   [[cell textLabel] setText: name];
   [[cell textLabel] setTextColor: [UIColor clearColor]];
   if ([[[cell textLabel] text] isEqualToString: [[Options sharedOptions]
                                                  valueForKey: @"colorScheme"]]) {
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
                                 forKey: @"colorScheme"];
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
