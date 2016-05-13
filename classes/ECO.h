/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import <Foundation/Foundation.h>

#import "Game.h"

@interface ECO : NSObject {
   NSMutableArray *openings;
}

+ (ECO *)sharedInstance;
- (NSString *)openingDescriptionForKey:(uint64_t)key;

@end
