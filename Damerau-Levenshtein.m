#import <Foundation/Foundation.h>

#import "NSString+DamerauLevenshtein.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSString *string1 = @"Hello, World!";
	NSString *string2 = @"Hallo, Welt!";
	
	NSUInteger levensteinDistance = [string1 distanceFromString:string2];
	NSLog(@"\nThe Levenstein distance between\n\"%@\"\nand\n\"%@\"\n=\n%ld", string1, string2, (long)levensteinDistance);
	
	[pool drain];
	return 0;
}
