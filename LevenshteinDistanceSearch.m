#import <Foundation/Foundation.h>

#import "JXTrie.h"

#define DICTIONARY	@"/usr/share/dict/words"
#define TARGET	@"goober"
#define MAX_COST	1

// Apparently, recreating the trie from the raw word list is faster than archiving/unarchiving using NSKeyedArchiver. 
#define ENABLE_ARCHIVING		0
#define ENABLE_ARRAY_ARCHIVING	0

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString *target;
	NSUInteger maxCost;
	NSString *dictionary;
	
	NSTimeInterval start;
	NSTimeInterval duration;
	
	if ([[[NSProcessInfo processInfo] arguments] count] < 3) {
		fprintf(stderr, "usage: %s [<search string> <maximum distance>] [<dictionary path>]\n",
				[[[NSProcessInfo processInfo] processName] UTF8String]);
		target = TARGET;
		maxCost = MAX_COST;
	}
	else {
		target = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
		maxCost = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:2] integerValue];
	}

	if ([[[NSProcessInfo processInfo] arguments] count] >= 3) {
		dictionary = [[[NSProcessInfo processInfo] arguments] objectAtIndex:3];
	}
	else {
		dictionary = DICTIONARY;
	}
	
#if ENABLE_ARCHIVING
	NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"trie.archive"];
#endif

#if !ENABLE_ARCHIVING && ENABLE_ARRAY_ARCHIVING
	NSString *arrayArchivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"word-list.archive"];
#endif
	
	JXTrie *trie;
	
#if ENABLE_ARCHIVING
	if ([[NSFileManager defaultManager] fileExistsAtPath:archivePath]) {
		start = [NSDate timeIntervalSinceReferenceDate];
		trie = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
		duration = [NSDate timeIntervalSinceReferenceDate] - start;
		NSLog(@"Read trie from archive: %lu words, %lu nodes. ", (unsigned long)[trie count], (unsigned long)[trie nodeCount]);
		NSLog(@"Reading the trie took %.4lf s. ", (double)duration);
	}
	else {
#endif
		// Read dictionary file into a trie
		NSArray *wordList;
		
		start = [NSDate timeIntervalSinceReferenceDate];
#if !ENABLE_ARCHIVING && ENABLE_ARRAY_ARCHIVING
		if ([[NSFileManager defaultManager] fileExistsAtPath:arrayArchivePath]) {
			wordList = [NSKeyedUnarchiver unarchiveObjectWithFile:arrayArchivePath];
		}
		else {
#endif

			NSString *wordListText = [NSString stringWithContentsOfFile:dictionary encoding:NSUTF8StringEncoding error:NULL];
			wordList = [wordListText componentsSeparatedByString:@"\n"];
			
#if !ENABLE_ARCHIVING && ENABLE_ARRAY_ARCHIVING
			BOOL result = [NSKeyedArchiver archiveRootObject:wordList
													  toFile:arrayArchivePath];
			if (result) {
				NSLog(@"Successfully archived word list to \"%@\". ", arrayArchivePath);
			}
			else {
				NSLog(@"Archiving word list to \"%@\" failed! ", arrayArchivePath);
			}
		}
#endif
		
		trie = [JXTrie trieWithStrings:wordList];
		duration = [NSDate timeIntervalSinceReferenceDate] - start;
		
		NSLog(@"Read %lu words into %lu nodes. ", (unsigned long)[trie count], (unsigned long)[trie nodeCount]);
		NSLog(@"Creating the trie for \"%@\" took %.4lf s. ", dictionary, (double)duration);
		
#if ENABLE_ARCHIVING
		BOOL result = [NSKeyedArchiver archiveRootObject:trie
												  toFile:archivePath];
		if (result) {
			NSLog(@"Successfully archived to \"%@\". ", archivePath);
		}
		else {
			NSLog(@"Archiving to \"%@\" failed! ", archivePath);
		}
	}
#endif
	
	NSArray *results = nil;
	
	start = [NSDate timeIntervalSinceReferenceDate];
	results = [trie search:target maximumDistance:maxCost];
    duration = [NSDate timeIntervalSinceReferenceDate] - start;
	
	NSLog(@"\n%@", results);
	
	NSLog(@"Search for \"%@\" took %.4lf s. ", target, (double)duration);
	
	[pool drain];
	return 0;
}
