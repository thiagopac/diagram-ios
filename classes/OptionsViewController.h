/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class BoardViewController;

@interface OptionsViewController : UITableViewController {
   BoardViewController *__weak boardViewController;
}

@property (weak, nonatomic, readonly) BoardViewController *boardViewController;

- (id)initWithBoardViewController:(BoardViewController *)bvc;
- (void)deselect:(UITableView *)tableView;
- (void)toggleShowAnalysis:(id)sender;
- (void)toggleShowBookMoves:(id)sender;
- (void)toggleShowLegalMoves:(id)sender;
- (void)toggleShowCoordinates:(id)sender;
- (void)toggleShowAnalysisArrows:(id)sender;
- (void)togglePermanentBrain:(id)sender;
- (void)toggleFigurines:(id)sender;
- (void)toggleSound:(id)sender;
- (void)updateTableCells;

@end
