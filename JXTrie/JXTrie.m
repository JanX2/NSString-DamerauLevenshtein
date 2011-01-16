//
//  JXTrie.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXTrie.h"

#import "JXTrieNode.h"


// Return the minimum of a, b and c - used by distanceFromString:options:
CF_INLINE CFIndex smallestCFIndex(CFIndex a, CFIndex b, CFIndex c) {
	CFIndex min = a;
	if ( b < min )
		min = b;
	
	if ( c < min )
		min = c;
	
	return min;
}

@interface JXTrie ()
@property (nonatomic, retain) JXTrieNode *rootNode;
@end


@implementation JXTrie

@synthesize rootNode;

+ (id)trieWithStrings:(NSArray *)wordList;
{
	return [[[JXTrie alloc] initWithStrings:wordList] autorelease];
}

- (id)initWithStrings:(NSArray *)wordList;
{
	self = [super init];
	if (self) {
		self.rootNode = [JXTrieNode new];
		nodeCount = 0;
		wordCount = 0;

		for (NSString *word in wordList) {
			[self insertWord:word];
			wordCount += 1;
		}
		
	}
	
    return self;
}


- (void)dealloc
{
	self.rootNode = nil;
	[super dealloc];
}


- (NSUInteger)nodeCount;
{
	return nodeCount;
}

- (NSUInteger)count;
{
	return wordCount;
}


- (void)insertWord:(NSString *)newWord;
{
	nodeCount += [self.rootNode insertWord:newWord];
	//NSLog(@"\n%@", [self description]);
}

// This recursive helper is used by the search function above. It assumes that
// the previousRow has been filled in already.
void searchRecursive(JXTrieNode *node, UniChar letter, CFStringRef word, UniChar *word_chars, CFIndex *previousRow, NSMutableArray *results, CFIndex maxCost) {
	
	CFIndex columns = CFStringGetLength(word) + 1;
	CFIndex currentRowLastIndex = columns - 1;
	CFIndex currentRow[columns];
	currentRow[0] = previousRow[0] + 1;
	
	CFIndex insertCost;
	CFIndex deleteCost;
	CFIndex replaceCost;
	
	CFIndex column;
	
	// Build one row for the letter, with a column for each letter in the target
	// word, plus one for the empty string at column 0
	for (column = 1; column < columns; column++) {
		
		insertCost = currentRow[column - 1] + 1;
		deleteCost = previousRow[column] + 1;
		
		if (word_chars[column - 1] != letter) {
			replaceCost = previousRow[column - 1] + 1;
		}
		else {
			replaceCost = previousRow[column - 1];
		}
		
		currentRow[column] = smallestCFIndex(insertCost, deleteCost, replaceCost);
		
	}
	
	// If the last entry in the row indicates the optimal cost is less than the
	// maximum cost, and there is a word in this trie node, then add it.
	if (currentRow[currentRowLastIndex] <= maxCost && node.word != nil) {
		[results addObject:[JXTrieResult resultWithWord:(NSString *)node.word 
											andDistance:currentRow[currentRowLastIndex]]];
	}
	
	CFIndex currentRowMinCost = currentRow[0];
	for (column = 1; column < columns; column++) {
		currentRowMinCost = MIN(currentRowMinCost, currentRow[column]);
	}
	
	// If any entries in the row are less than the maximum cost, then 
	// recursively search each branch of the trie
	if (currentRowMinCost <= maxCost) {
		for (NSString *letter in node.children) {
			searchRecursive( [node.children objectForKey:letter], [letter characterAtIndex:0], word, word_chars, currentRow, results, maxCost);
		}
	}
}

- (NSArray *)search:(NSString *)word maximumDistance:(NSUInteger)maxCost;
{
	CFIndex word_length = CFStringGetLength((CFStringRef)word);
	const UniChar *word_chars;
	UniChar *word_buffer = NULL;

	word_chars = CFStringGetCharactersPtr((CFStringRef)word);
	if (word_chars == NULL) {
		// Fallback in case CFStringGetCharactersPtr() didn’t work. 
		word_buffer = malloc(word_length * sizeof(UniChar));
		CFStringGetCharacters((CFStringRef)word, CFRangeMake(0, word_length), word_buffer);
		word_chars = word_buffer;
	}
	
	// build first row
	CFIndex currentRowSize = word_length + 1;
	CFIndex currentRow[currentRowSize];
	for (CFIndex k = 0; k < currentRowSize; k++) {
		currentRow[k] = k;
	}
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSMutableDictionary *rootNodeChildren = self.rootNode.children;
	
	// recursively search each branch of the trie
	for (NSString *letter in rootNodeChildren) {
		searchRecursive([rootNodeChildren objectForKey:letter], [letter characterAtIndex:0], (CFStringRef)word, (UniChar *)word_chars, currentRow, 
						results, maxCost);
	}
		
	if (word_buffer != NULL) {
		free(word_buffer);
	}

	return results;
}


- (NSString *)description
{
	return [rootNode description];
}


@end