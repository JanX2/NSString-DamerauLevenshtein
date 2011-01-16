#import <Foundation/Foundation.h>

#import "JXTrie.h"

#define DICTIONARY	@"/usr/share/dict/words"
#define TARGET	@"goober"
#define MAX_COST	1

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
	// Read dictionary file into a trie
	NSString *wordListText = [NSString stringWithContentsOfFile:DICTIONARY encoding:NSUTF8StringEncoding error:NULL];
	NSArray *wordList = [wordListText componentsSeparatedByString:@"\n"];
	
	JXTrie *trie = [JXTrie trieWithStrings:wordList];
	
	NSLog(@"Read %d words into %d nodes", [trie count], [trie nodeCount]);
	
	NSArray *results = nil;
	
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	results = [trie search:TARGET maximumDistance:MAX_COST];
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
	
	NSLog(@"\n%@", results);
	
	NSLog(@"Search for \"%@\" took %.4lf", TARGET, (double)duration);
	
	[pool drain];
	return 0;
}
