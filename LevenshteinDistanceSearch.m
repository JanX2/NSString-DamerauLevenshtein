#import <Foundation/Foundation.h>

#import "JXTrie.h"

#define DICTIONARY	@"/usr/share/dict/words"
#define TARGET	@"goober"
#define MAX_COST	1

// Apparently, recreating the trie is more efficient than archiving/unarchiving using NSKeyedArchiver for large tries. 
#define ENABLE_ARCHIVING	NO

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString *target;
	NSUInteger maxCost;
	
	NSTimeInterval start;
	NSTimeInterval duration;
	
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
	
	NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"trie.archive"];
	JXTrie *trie;
	
	if (ENABLE_ARCHIVING && [[NSFileManager defaultManager] fileExistsAtPath:archivePath]) {
		start = [NSDate timeIntervalSinceReferenceDate];
		trie = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
		duration = [NSDate timeIntervalSinceReferenceDate] - start;
		NSLog(@"Read trie from archive: %lu words, %lu nodes. ", (unsigned long)[trie count], (unsigned long)[trie nodeCount]);
		NSLog(@"Reading the trie took %.4lf s. ", (double)duration);
	}
	else {
		// Read dictionary file into a trie
		start = [NSDate timeIntervalSinceReferenceDate];
		NSString *wordListText = [NSString stringWithContentsOfFile:DICTIONARY encoding:NSUTF8StringEncoding error:NULL];
		NSArray *wordList = [wordListText componentsSeparatedByString:@"\n"];
		
		trie = [JXTrie trieWithStrings:wordList];
		duration = [NSDate timeIntervalSinceReferenceDate] - start;
		
		NSLog(@"Read %lu words into %lu nodes. ", (unsigned long)[trie count], (unsigned long)[trie nodeCount]);
		NSLog(@"Creating the trie for \"%@\" took %.4lf s. ", DICTIONARY, (double)duration);
		
		if (ENABLE_ARCHIVING) {
			BOOL result = [NSKeyedArchiver archiveRootObject:trie
													  toFile:archivePath];
			if (result) {
				NSLog(@"Successfully archived to \"%@\". ", archivePath);
			}
			else {
				NSLog(@"Archiving to \"%@\" failed! ", archivePath);
			}
		}
	}
	
	NSArray *results = nil;
	
	start = [NSDate timeIntervalSinceReferenceDate];
	results = [trie search:target maximumDistance:maxCost];
    duration = [NSDate timeIntervalSinceReferenceDate] - start;
	
	NSLog(@"\n%@", results);
	
	NSLog(@"Search for \"%@\" took %.4lf s. ", target, (double)duration);
	
	[pool drain];
	return 0;
}
