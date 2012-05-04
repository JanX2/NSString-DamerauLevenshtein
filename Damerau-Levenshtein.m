#import <Foundation/Foundation.h>

#import "NSString+DamerauLevenshtein.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSString *string1 = @"Hello, World!";
	NSString *string2 = @"Hallo, Welt!";
	NSString *string1trans = @"Hello, Wrold!";
	
	NSUInteger levensteinDistance;
	
	levensteinDistance = [string1 distanceFromString:string2];
	NSLog(@"\nThe Levenstein distance between\n\"%@\"\nand\n\"%@\"\n=\n%ld", string1, string2, (long)levensteinDistance);
	
	levensteinDistance = [string1 distanceFromString:string1trans];
	NSString *resultDescription;
	switch (levensteinDistance) {
		case 1:
			resultDescription = @"enabled";
			break;
		case 2:
			resultDescription = @"disabled";
			break;
		default:
			resultDescription = @"broken";
			break;
	}

	NSLog(@"Damerau transposition %@. ", resultDescription);

	float semanticDistance = [string1 semanticDistanceFromString:string2];
	NSLog(@"\nThe semantic distance between\n\"%@\"\nand\n\"%@\"\n=\n%f", string1, string2, semanticDistance);
	
	[pool drain];
	return 0;
}
