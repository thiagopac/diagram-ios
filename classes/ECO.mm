/*
  Diagram
  Created by Thiago Castro
  Copyright (c) 2016 Thiago Castro. All rights reserved.
*/

#import "ECO.h"
#import "Game.h"
#import "PGN.h"

@interface Opening : NSObject {
   uint64_t key;
   NSString *__strong ecoCode, *__strong opening, *__strong variation;
}

@property (readonly, atomic) uint64_t key;
@property (strong, readonly, atomic) NSString *ecoCode;
@property (strong, readonly, atomic) NSString *opening;
@property (strong, readonly, atomic) NSString *variation;

- (id)initWithString:(NSString *)string;

@end // @interface Opening

@implementation Opening

@synthesize key, ecoCode, opening, variation;

- (id)initWithString:(NSString *)string {
   if (self = [super init]) {
      NSScanner *scanner = [NSScanner scannerWithString: string];
      NSString *s;
      [scanner scanHexLongLong: &key];

      [scanner scanUpToString: @"\"" intoString: NULL];
      [scanner scanString: @"\"" intoString: NULL];
      [scanner scanUpToString: @"\"" intoString: &s];
      ecoCode = [NSString stringWithString: s];
      [scanner scanString: @"\"" intoString: NULL];
      
      [scanner scanUpToString: @"\"" intoString: NULL];
      [scanner scanString: @"\"" intoString: NULL];
      [scanner scanUpToString: @"\"" intoString: &s];
      opening = [NSString stringWithString: s];
      [scanner scanString: @"\"" intoString: NULL];
      
      [scanner scanUpToString: @"\"" intoString: NULL];
      [scanner scanString: @"\"" intoString: NULL];
      [scanner scanUpToString: @"\"" intoString: &s];
      variation = [NSString stringWithString: s];
      [scanner scanString: @"\"" intoString: NULL];
   }
   return self;
}


@end

@implementation ECO


+ (ECO *)sharedInstance {
   static ECO *e = nil;
   if (e == nil)
      e = [[ECO alloc] init];
   return e;
}


- (id)init {
   if (self = [super init]) {
      openings = [[NSMutableArray alloc] init];

      NSString *path = [[NSBundle bundleForClass: [self class]]
                          pathForResource: @"eco"
                                   ofType: @"txt"];
      NSString *contents =
         [NSString stringWithContentsOfFile: path
                                   encoding: NSASCIIStringEncoding
                                      error: nil];
      NSArray *lines =
         [contents componentsSeparatedByCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString: @"\n"]];
      Opening *o;
      for (NSString *line in lines) {
         if ([line isEqualToString: @""]) break;
         o = [[Opening alloc] initWithString: line];
         [openings addObject: o];
      }
   }
   return self;
}


- (NSString *)openingDescriptionForKey:(uint64_t)key {
   int min = 0, max = (int)[openings count] - 1, mid;
   Opening *o;

   while (max >= min) {
      mid = (max + min) / 2;
      o = [openings objectAtIndex: mid];
      if ([o key] < key)
         min = mid + 1;
      else if ([o key] > key)
         max = mid - 1;
      else if ([[o variation] isEqualToString: @"(null)"]) {
         return [NSString stringWithFormat: @"%@ %@",
                          [o ecoCode], [o opening]];
      }
      else {
         return [NSString stringWithFormat: @"%@ %@, %@",
                          [o ecoCode], [o opening], [o variation]];
      }
   }
   return nil;
}



@end
