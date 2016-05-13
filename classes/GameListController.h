/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <UIKit/UIKit.h>

@class LoadFileListController;
@class PGN;

@interface GameListController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate> {
   LoadFileListController *loadFileListController;
   NSString *filename;
   PGN *pgnFile;
   BOOL isReadonly;
   BOOL firstAppearance;
   UISearchDisplayController *searchDisplayController;
}

- (id)initWithLoadFileListController:(LoadFileListController *)lflc
                            filename:(NSString *)aFilename
                          isReadonly:(BOOL)readonly;

@end
