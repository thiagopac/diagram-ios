/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "Queue.h"


@implementation Queue

- (id)init {
   if (self = [super init]) {
      contents = [[NSMutableArray alloc] init];
   }
   return self;
}

- (BOOL)isEmpty {
   return [self size] == 0;
}

- (int)size {
   return (int)[contents count];
}

- (id)front {
   return [contents objectAtIndex: 0];
}

- (id)back {
   return [contents lastObject];
}

- (void)push:(id)anObject {
   [contents addObject: anObject];
}

- (id)pop {
   id object = nil;
   if (![self isEmpty]) {
      object = [contents objectAtIndex: 0];
      [contents removeObjectAtIndex: 0];
   }
   else
      NSLog(@"Queue undeflow!");

   return object;
}


@end
