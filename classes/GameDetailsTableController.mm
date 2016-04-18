/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2014 Tord Romstad, Marco Costalba, Joona Kiiski.

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "BoardViewController.h"
#import "DateTagViewController.h"
#import "EmailAddressController.h"
#import "Game.h"
#import "GameDetailsTableController.h"
#import "Options.h"
#import "PGNTextFieldController.h"
#import "ResultTagViewController.h"
#import "SaveFileListController.h"


@implementation GameDetailsTableController

@synthesize game;

- (id)initWithBoardViewController:(BoardViewController *)bvc
                             game:(Game *)aGame
                            email:(BOOL)mail {
   if (self = [super initWithStyle: UITableViewStyleGrouped]) {
      //[self setTitle: @"Edit Game Data"];
      boardViewController = bvc;
      game = aGame;
      email = mail;
      [self setPreferredContentSize: CGSizeMake(320.0f, 400.0f)];
   }
   return self;
}


- (void)loadView {
   [super loadView];
   [[self navigationItem] setRightBarButtonItem:
                             [[UIBarButtonItem alloc]
                                 initWithTitle: (email? @"E-mail" : @"Save")
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: (email?
                                                 @selector(emailMenuDonePressed) :
                                                 @selector(saveMenuDonePressed))]];
   [[self navigationItem] setLeftBarButtonItem:
                             [[UIBarButtonItem alloc]
                                 initWithTitle: @"Cancel"
                                         style: UIBarButtonItemStylePlain
                                        target: boardViewController
                                        action: (email?
                                                 @selector(emailMenuCancelPressed) :
                                                 @selector(saveMenuCancelPressed))]];
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   switch(section) {
   case 0: // PGN tags
      return 7;
   case 1: // PGN file
      return 1;
   default:
      assert(NO);
   }
   return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   NSInteger section = [indexPath section];

   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil)
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                     reuseIdentifier: @"cell"];

   if (section == 0) {
      if (row == 0) {
         [[cell textLabel] setText: @"White"];
         [[cell detailTextLabel] setText: [game whitePlayer]];
         //[cell setValueText: [game whitePlayer]];
      }
      else if (row == 1) {
         [[cell textLabel] setText: @"Black"];
         [[cell detailTextLabel] setText: [game blackPlayer]];
         //[cell setValueText: [game blackPlayer]];
      }
      else if (row == 2) {
         [[cell textLabel] setText: @"Event"];
         [[cell detailTextLabel] setText: [game event]];
         //[cell setValueText: [game event]];
      }
      else if (row == 3) {
         [[cell textLabel] setText: @"Site"];
         [[cell detailTextLabel] setText: [game site]];
         //[cell setValueText: [game site]];
      }
      else if (row == 4) {
         [[cell textLabel] setText: @"Date"];
         [[cell detailTextLabel] setText: [game date]];
         //[cell setValueText: [game date]];
      }
      else if (row == 5) {
         [[cell textLabel] setText: @"Round"];
         [[cell detailTextLabel] setText: [game round]];
         //[cell setValueText: [game round]];
      }
      else if (row == 6) {
         [[cell textLabel] setText: @"Result"];
         [[cell detailTextLabel] setText: [game result]];
         //[cell setValueText: [game result]];
      }
      [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
   }
   else if (section == 1) {
      if (email) {
         [[cell textLabel] setText: @"Recipient"];
         [[cell detailTextLabel] setText: [[Options sharedOptions] emailAddress]];
         //[cell setValueText: [[Options sharedOptions] emailAddress]];
         [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
      }
      else {
         [[cell textLabel] setText: @"File name"];
         [[cell detailTextLabel] setText: [[Options sharedOptions] saveGameFile]];
         //[cell setValueText: [[Options sharedOptions] saveGameFile]];
         [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
      }
   }
   return cell;
}



- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   NSInteger section = [indexPath section];

   [self performSelector: @selector(deselect:) withObject: tableView
              afterDelay: 0.1f];

   if (section == 0) { // PGN tags
      PGNTextFieldController *pgnTFC = nil;
      if (row == 0) {
         pgnTFC =
            [[PGNTextFieldController alloc] initWithGameDetailsController: self
                                                                   pgnTag: @"whitePlayer"];
         [[self navigationController] pushViewController: pgnTFC animated: YES];
      }
      else if (row == 1) {
         pgnTFC =
            [[PGNTextFieldController alloc] initWithGameDetailsController: self
                                                                   pgnTag: @"blackPlayer"];
         [[self navigationController] pushViewController: pgnTFC animated: YES];
      }
      else if (row == 2) {
         pgnTFC =
            [[PGNTextFieldController alloc] initWithGameDetailsController: self
                                                                   pgnTag: @"event"];
         [[self navigationController] pushViewController: pgnTFC animated: YES];
      }
      else if (row == 3) {
         pgnTFC =
            [[PGNTextFieldController alloc] initWithGameDetailsController: self
                                                                   pgnTag: @"site"];
         [[self navigationController] pushViewController: pgnTFC animated: YES];
      }
      else if (row == 4) {
         DateTagViewController *dtvc =
            [[DateTagViewController alloc] initWithGameDetailsController: self];
         [[self navigationController] pushViewController: dtvc animated: YES];
      }
      else if (row == 5) {
         pgnTFC =
            [[PGNTextFieldController alloc] initWithGameDetailsController: self
                                                                   pgnTag: @"round"];
         [[self navigationController] pushViewController: pgnTFC animated: YES];
      }
      else if (row == 6) {
         ResultTagViewController *rtvc =
            [[ResultTagViewController alloc] initWithGameDetailsController: self];
         [[self navigationController] pushViewController: rtvc animated: YES];
      }
      else
         assert(NO);
      // [pgnTFC release];
   }
   else if (section == 1) { // E-mail address or PGN file
      if (email) {
         EmailAddressController *eac = [[EmailAddressController alloc]
                                          initWithGameDetailsController: self];
         [[self navigationController] pushViewController: eac animated: YES];
      }
      else {
         SaveFileListController *sflc = [[SaveFileListController alloc]
                                           initWithGameDetailsController: self];
         [[self navigationController] pushViewController: sflc animated: YES];
      }
   }
}


- (void)deselect:(UITableView *)tableView {
   [[self tableView] deselectRowAtIndexPath:
                        [[self tableView] indexPathForSelectedRow]
                                   animated: YES];
}


- (void)updateTableCells {
   [[self tableView] reloadData];
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
   if (buttonIndex == 1) {
      if ([[alertView message] isEqualToString: @"You have not specified the result of the game. Really e-mail game without a result?"])
         [boardViewController emailMenuDonePressed];
      else
         [boardViewController saveMenuDonePressed];
   }
}


- (void)emailMenuDonePressed {
   if ([[game result] isEqualToString: @"*"])
      [[[UIAlertView alloc] initWithTitle: @"Game has no result"
                                   message: @"You have not specified the result of the game. Really e-mail game without a result?"
                                  delegate: self
                         cancelButtonTitle: @"Cancel"
                         otherButtonTitles: @"OK", nil]
         show];
   else
      [boardViewController emailMenuDonePressed];
}


- (void)saveMenuDonePressed {
   //NSLog(@"saving to %@", PGN_DIRECTORY);
   if ([[game result] isEqualToString: @"*"])
      [[[UIAlertView alloc] initWithTitle: @"Game has no result"
                                   message: @"You have not specified the result of the game. Really save game without a result?"
                                  delegate: self
                         cancelButtonTitle: @"Cancel"
                         otherButtonTitles: @"OK", nil]
         show];
   else
      [boardViewController saveMenuDonePressed];
}




@end
