#import "Util.h"

#include <sys/sysctl.h>

@implementation Util


+ (unsigned)CPUCount {
   unsigned cpucount;
   size_t s = sizeof(cpucount);
   sysctlbyname("hw.ncpu", &cpucount, &s, NULL, 0);
   return cpucount;
}


+ (NSString *)translateToFigurine:(NSString *)string {
   unichar c;
   NSString *result = [NSString stringWithString: string], *s;
   NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
   int i;
   for (i = 0, c = 0x2654; i < 5; i++, c++) {
      s = [NSString stringWithCharacters:&c length:1];
      result = [result stringByReplacingOccurrencesOfString:pc[i] withString:s];
   }
   return result;
}

@end
