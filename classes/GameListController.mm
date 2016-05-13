/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "GameListController.h"
#import "GamePreview.h"
#import "LoadFileListController.h"
#import "Options.h"
#import "PGN.h"

@implementation GameListController

- (id)initWithLoadFileListController:(LoadFileListController *)lflc
                            filename:(NSString *)aFilename
                          isReadonly:(BOOL)readonly {
   if (self = [super init]) {
      loadFileListController = lflc;
      filename = aFilename;
      isReadonly = readonly;
      pgnFile = [[PGN alloc] initWithFilename: filename];
      [pgnFile initializeGameIndices];
   }
   return self;
}


- (void)loadView {
   [super loadView];

   NSString *title =
      [[[filename componentsSeparatedByString: @"/"] lastObject]
       stringByReplacingOccurrencesOfString: @".pgn" withString: @""];
   [[self navigationItem] setTitle: title];
   if (!isReadonly)
      [[self navigationItem] setRightBarButtonItem: [self editButtonItem]];
   firstAppearance = true;
}


- (void)viewDidLoad {
   [super viewDidLoad];
   
   // Set up a search bar:
   UISearchBar *searchBar = [[UISearchBar alloc] init];
   [searchBar sizeToFit];
   [searchBar setDelegate: self];
   [[self tableView] setTableHeaderView: searchBar];
   [[self tableView] reloadData];
   [[self tableView] scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: 0
                                                                inSection: 0]
                           atScrollPosition: UITableViewScrollPositionTop
                                   animated: NO];
   searchDisplayController = [[UISearchDisplayController alloc]
                              initWithSearchBar: searchBar
                              contentsController: self];
   [searchDisplayController setDelegate: self];
   [searchDisplayController setSearchResultsDataSource: self];
   [searchDisplayController setSearchResultsDelegate: self];
}


- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear: animated];
   if (!firstAppearance) {
      [[Options sharedOptions] setLoadGameFile: @""];
      [[Options sharedOptions] setLoadGameFileGameNumber: 0];
      if ([pgnFile isEmpty]) {
         NSLog(@"Game list view reappeared");
         // Ask parent view controller to remove the row representing this file,
         // and pop out
         //[loadFileListController removeItemWithFilename: filename];
         //[[self navigationController] popViewControllerAnimated: YES];
      }
   }
   firstAppearance = false;
   if (![[[Options sharedOptions] loadGameFile] isEqualToString: @""]) {
      int loadGameNumber = [[Options sharedOptions] loadGameFileGameNumber];
      if (loadGameNumber < [pgnFile numberOfGames]) {
         NSIndexPath *path = [NSIndexPath indexPathForRow: loadGameNumber
                                                inSection: 0];
         [[self tableView] selectRowAtIndexPath: path
                                       animated: NO
                                 scrollPosition: UITableViewScrollPositionMiddle];
         [self tableView: [self tableView] didSelectRowAtIndexPath: path];
      }
   }
   if ([[Options sharedOptions] displayGameListSearchFieldHint]) {
      [[[UIAlertView alloc] initWithTitle: @"Hint:"
                                   message: @"Scroll up to see a search field where you can enter a player's name to see only his/her games in this database."
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
       show];
   }
}


- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return (tableView == [searchDisplayController searchResultsTableView]) ?
   [pgnFile numberOfFilteredGames] : [pgnFile numberOfGames];
   //return [pgnFile numberOfGames];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
   UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier: @"cell"];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: @"cell"];
      [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
   }
   BOOL searchbarUsed = tableView == [searchDisplayController searchResultsTableView];
   //NSLog(@"search bar used: %d", searchbarUsed);
   [pgnFile goToGameNumber: (int)row useFilter: searchbarUsed];
   [[cell textLabel] setText: [NSString stringWithFormat: @"%@-%@ %@",
                               [pgnFile white], [pgnFile black], [pgnFile result]]];

   return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:
   (NSIndexPath *)newIndexPath {
   NSInteger row = [newIndexPath row];

   if (row >= 0) {
      GamePreview *gp = [[GamePreview alloc] initWithPGN:pgnFile gameNumber:(int) row
                                      gameListController:self
                                              isReadonly:isReadonly];
       
       
      [[self navigationController] pushViewController:gp animated:YES];
   }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   return !isReadonly;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
   return UITableViewCellEditingStyleDelete;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
   [super setEditing: editing animated: animated];
   [[self tableView] setEditing: editing animated: animated];
}



- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
   if ([pgnFile filterIsActive]) {
      [[[UIAlertView alloc] initWithTitle: @""
                                   message: @"Deletion of games in databases filtered by a search is currently not supported. This problem will be fixed in a future version. We apologize for the inconvenience."
                                  delegate: self
                         cancelButtonTitle: nil
                         otherButtonTitles: @"OK", nil]
       show];
      return;
   }
   NSInteger row = [indexPath row];
   [pgnFile deleteGameNumber: (int)row];
   [tableView deleteRowsAtIndexPaths: @[indexPath]
                    withRowAnimation: UITableViewRowAnimationAutomatic];
   if ([pgnFile isEmpty]) {
      // Ask parent view controller to remove the row representing this file,
      // and pop out
      [loadFileListController removeItemWithFilename: filename];
      [[self navigationController] popViewControllerAnimated: YES];
   }
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   //NSLog(@"searching for string %@", searchText);
   if ([searchText isEqualToString: @""])
      [pgnFile clearFilter];
   else
      [pgnFile filterByPlayerName: searchText];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
   //NSLog(@"searching for player %@", [searchBar text]);
   //[pgnFile filterByPlayerName: [searchBar text]];
   //[[self tableView] reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
   [pgnFile clearFilter];
}



@end
