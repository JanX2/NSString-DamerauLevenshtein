//
//  JXTrie.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXTrie.h"

#import "JXTrieNode.h"
#import "JXLDStringDistanceUtilities.h"


@interface JXTrie ()
@property (nonatomic, retain) JXTrieNode *rootNode;
@end


@implementation JXTrie

@synthesize rootNode;


void searchRecursive(JXTrieNode *node, UniChar prevLetter, UniChar thisLetter, CFStringRef word, UniChar *word_chars, CFIndex columns, CFIndex *penultimateRow, CFIndex *previousRow, NSMutableArray *results, CFIndex maxCost);


+ (id)trieWithStrings:(NSArray *)wordList;
{
	return [[[JXTrie alloc] initWithStrings:wordList options:0] autorelease];
}

+ (id)trieWithStrings:(NSArray *)wordList options:(JXLDStringDistanceOptions)options;
{
	return [[[JXTrie alloc] initWithStrings:wordList options:options] autorelease];
}

- (id)initWithStrings:(NSArray *)wordList;
{
	return [self initWithStrings:wordList options:0];
}

- (id)initWithStrings:(NSArray *)wordList options:(JXLDStringDistanceOptions)options;
{
	self = [super init];
	if (self) {
		rootNode = [JXTrieNode new];
		nodeCount = 0;
		wordCount = 0;
		optionFlags = options;

		if (optionFlags) {
			CFMutableStringRef string;
			
			for (NSString *word in wordList) {
				string = (CFMutableStringRef)[word mutableCopy];
				jxld_CFStringPreprocessWithOptions(string, optionFlags);
				
				[self insertWord:(NSString *)string];
				wordCount += 1;
				
				CFRelease(string);
			}
		}
		else {
			for (NSString *word in wordList) {
				[self insertWord:word];
				wordCount += 1;
			}
		}
		
	}
	
    return self;
}


- (void)dealloc
{
	self.rootNode = nil;
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder
{		
	self = [super init];
	if (self) {
		self.rootNode = [coder decodeObjectForKey:@"rootNode"];
		nodeCount = [coder decodeIntegerForKey:@"nodeCount"];
		wordCount = [coder decodeIntegerForKey:@"wordCount"];
		
		BOOL caseInsensitive		= [coder decodeBoolForKey:@"caseInsensitive"];
		BOOL literal				= [coder decodeBoolForKey:@"literal"];
		BOOL whitespaceInsensitive	= [coder decodeBoolForKey:@"whitespaceInsensitive"];
		BOOL whitespaceTrimming		= [coder decodeBoolForKey:@"whitespaceTrimming"];
		BOOL diacriticInsensitive	= [coder decodeBoolForKey:@"diacriticInsensitive"];
		BOOL widthInsensitive		= [coder decodeBoolForKey:@"widthInsensitive"];
		
		optionFlags = 0;
		if (caseInsensitive)		optionFlags |= JXLDCaseInsensitiveComparison;
		if (literal)				optionFlags |= JXLDLiteralComparison;
		if (whitespaceInsensitive)	optionFlags |= JXLDWhitespaceInsensitiveComparison;
		if (whitespaceTrimming)		optionFlags |= JXLDWhitespaceTrimmingComparison;
		if (diacriticInsensitive)	optionFlags |= JXLDDiacriticInsensitiveComparison;
		if (widthInsensitive)		optionFlags |= JXLDWidthInsensitiveComparison;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{	
	[coder encodeObject:rootNode forKey:@"rootNode"];
	[coder encodeInteger:nodeCount forKey:@"nodeCount"];
	[coder encodeInteger:wordCount forKey:@"wordCount"];
	
	BOOL caseInsensitive		 = optionFlags & JXLDCaseInsensitiveComparison;
	BOOL literal				 = optionFlags & JXLDLiteralComparison;
	BOOL whitespaceInsensitive	 = optionFlags & JXLDWhitespaceInsensitiveComparison;
	BOOL whitespaceTrimming		 = optionFlags & JXLDWhitespaceTrimmingComparison;
    BOOL diacriticInsensitive	 = optionFlags & JXLDDiacriticInsensitiveComparison;
    BOOL widthInsensitive		 = optionFlags & JXLDWidthInsensitiveComparison;
	
	[coder encodeBool:caseInsensitive		forKey:@"caseInsensitive"];
	[coder encodeBool:literal				forKey:@"literal"];
	[coder encodeBool:whitespaceInsensitive	forKey:@"whitespaceInsensitive"];
	[coder encodeBool:whitespaceTrimming	forKey:@"whitespaceTrimming"];
	[coder encodeBool:diacriticInsensitive	forKey:@"diacriticInsensitive"];
	[coder encodeBool:widthInsensitive		forKey:@"widthInsensitive"];
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
void searchRecursive(JXTrieNode *node, UniChar prevLetter, UniChar thisLetter, CFStringRef word, UniChar *word_chars, CFIndex columns, CFIndex *penultimateRow, CFIndex *previousRow, NSMutableArray *results, CFIndex maxCost) {
	
	CFIndex currentRowLastIndex = columns - 1;
	CFIndex *currentRow = malloc(columns * sizeof(CFIndex));
	currentRow[0] = previousRow[0] + 1;
	
	CFIndex cost;
	CFIndex insertCost;
	CFIndex deleteCost;
	CFIndex replaceCost;
	
	CFIndex column;
	
	// Build one row for the letter, with a column for each letter in the target
	// word, plus one for the empty string at column 0
	for (column = 1; column < columns; column++) {
		
		insertCost = currentRow[column - 1] + 1;
		deleteCost = previousRow[column] + 1;
		
		if (word_chars[column - 1] != thisLetter) {
			cost = 1;
		}
		else {
			cost = 0;
		}
		replaceCost = previousRow[column - 1] + cost;
		
		currentRow[column] = jxld_smallestCFIndex(insertCost, deleteCost, replaceCost);

#ifndef DISABLE_DAMERAU_TRANSPOSITION
		// This conditional adds Damerau transposition to the Levenshtein distance
		if (column > 1 && penultimateRow != NULL
			&& word_chars[column - 1] == prevLetter 
			&& word_chars[column - 2] == thisLetter )
		{
			currentRow[column] = MIN(currentRow[column],
									 penultimateRow[column - 2] + cost );
		}
#endif
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
		UniChar *keys;
		CFIndex keys_count = [node children_keys:&keys];
		UniChar nextLetter;
		for (CFIndex i = 0; i < keys_count; i++) {
			nextLetter = keys[i];
			searchRecursive( CFDictionaryGetValue(node.children, (void *)nextLetter), thisLetter, nextLetter, word, word_chars, columns, previousRow, currentRow, results, maxCost);
		}
	}
	
	free(currentRow);
}

- (NSArray *)search:(NSString *)word maximumDistance:(NSUInteger)maxCost;
{
	CFStringRef string;
	
	if (optionFlags) {
		string = (CFStringRef)[word mutableCopy];
		jxld_CFStringPreprocessWithOptions((CFMutableStringRef)string, optionFlags);
	}
	else {
		string = (CFStringRef)[word retain];
	}
	
	CFIndex string_length = CFStringGetLength(string);
	const UniChar *string_chars;
	UniChar *string_buffer = NULL;

	jxld_CFStringPrepareUniCharBuffer(string, &string_chars, &string_buffer, CFRangeMake(0, string_length));
	
	// build first row
	CFIndex currentRowSize = string_length + 1;
	CFIndex currentRow[currentRowSize];
	for (CFIndex k = 0; k < currentRowSize; k++) {
		currentRow[k] = k;
	}
	
	NSMutableArray *results = [NSMutableArray array];
	
	JXTrieNode *selfRootNode = self.rootNode;
	CFMutableDictionaryRef rootNodeChildren = selfRootNode.children;
	
	UniChar *keys;
	CFIndex keys_count = [selfRootNode children_keys:&keys];
	UniChar nextLetter;
	// recursively search each branch of the trie
	for (CFIndex i = 0; i < keys_count; i++) {
		nextLetter = keys[i];
		searchRecursive( CFDictionaryGetValue(rootNodeChildren, (void *)nextLetter), 0, nextLetter, string, (UniChar *)string_chars, string_length+1, NULL, currentRow, 
						results, maxCost);
	}
		
	if (string_buffer != NULL) {
		free(string_buffer);
	}
	
	CFRelease(string);

	return results;
}


- (NSString *)description
{
	return [rootNode description];
}


@end
