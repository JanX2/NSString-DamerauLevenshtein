#import <Foundation/Foundation.h>

#import "JXTrie.h"

#define DICTIONARY	@"/usr/share/dict/words"
#define TARGET	@"goober"
#define MAX_COST	1

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString *target;
	NSUInteger maxCost;
	
	if ([[[NSProcessInfo processInfo] arguments] count] < 3) {
		fprintf(stderr, "usage: %s <search string> <maximum distance>\n",
				[[[NSProcessInfo processInfo] processName] UTF8String]);
		target = TARGET;
		maxCost = MAX_COST;
	}
	else {
		target = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
		maxCost = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:2] integerValue];
	}
	
	// Read dictionary file into a trie
	NSString *wordListText = [NSString stringWithContentsOfFile:DICTIONARY encoding:NSUTF8StringEncoding error:NULL];
	NSArray *wordList = [wordListText componentsSeparatedByString:@"\n"];
	
	JXTrie *trie = [JXTrie trieWithStrings:wordList];
	
	NSLog(@"Read %lu words into %lu nodes", (unsigned long)[trie count], (unsigned long)[trie nodeCount]);
	
	NSArray *results = nil;
	
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	results = [trie search:target maximumDistance:maxCost];
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
	
	NSLog(@"\n%@", results);
	
	NSLog(@"Search for \"%@\" took %.4lf", target, (double)duration);
	
	[pool drain];
	return 0;
}
