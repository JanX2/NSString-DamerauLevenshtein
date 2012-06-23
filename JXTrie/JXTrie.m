//
//  JXTrie.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//

#import "JXTrie.h"

#import "JXTrieNode.h"
#import "JXLDStringDistanceUtilities.h"


@interface JXTrie ()
@property (nonatomic, retain) JXTrieNode *rootNode;
@end


@implementation JXTrie

@synthesize rootNode;


void searchRecursive(JXTrieNode *node, 
					 UniChar prevLetter, UniChar thisLetter, 
					 UniChar *word_chars, CFIndex columns, 
					 CFIndex *penultimateRow, CFIndex *previousRow, 
					 UniChar *result_chars, CFIndex row_index, 
					 NSMutableArray *results, 
					 CFIndex maxCost);

NSMutableArray * searchCore(JXTrieNode *rootNode, 
							const UniChar *string_chars, CFIndex string_length, 
							NSUInteger maxCost);
+ (id)trie;
{
	return [[[JXTrie alloc] initWithOptions:0] autorelease];
}

+ (id)trieWithOptions:(JXLDStringDistanceOptions)options;
{
	return [[[JXTrie alloc] initWithOptions:options] autorelease];
}

- (id)init;
{
	return [self initWithOptions:0];
}

- (id)initWithOptions:(JXLDStringDistanceOptions)options;
{
	self = [super init];
	
	if (self) {
		rootNode = [JXTrieNode new];
		nodeCount = 0;
		wordCount = 0;
		optionFlags = options;
	}
	
	return self;
}

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
	self = [self initWithOptions:options];
	
	if (self == nil)  return nil;
	
	if (optionFlags) {
		CFMutableStringRef string;
		
		for (NSString *word in wordList) {
			string = (CFMutableStringRef)[word mutableCopy];
			jxld_CFStringPreprocessWithOptions(string, optionFlags);
			
			nodeCount += [rootNode insertWord:(NSString *)string];
			wordCount += 1;
			
			CFRelease(string);
		}
	}
	else {
		for (NSString *word in wordList) {
			nodeCount += [rootNode insertWord:(NSString *)word];
			wordCount += 1;
		}
	}
	
    return self;
}


+ (id)trieWithWordListString:(NSString *)wordListString;
{
	return [[[JXTrie alloc] initWithWordListString:wordListString options:0] autorelease];
}

+ (id)trieWithWordListString:(NSString *)wordListString options:(JXLDStringDistanceOptions)options;
{
	return [[[JXTrie alloc] initWithWordListString:wordListString options:options] autorelease];
}

- (id)initWithWordListString:(NSString *)wordListString;
{
	return [self initWithWordListString:wordListString options:0];
}

- (id)initWithWordListString:(NSString *)wordListString options:(JXLDStringDistanceOptions)options;
{
	self = [self initWithOptions:options];
	
	if (self == nil)  return nil;
	
	if (optionFlags) {
		CFMutableStringRef preparedWordListString = (CFMutableStringRef)[wordListString mutableCopy];
		
		jxld_CFStringPreprocessWithOptions(preparedWordListString, optionFlags);
		
		wordListString = [(NSString *)preparedWordListString autorelease];
	}
	
	NSUInteger wordListStringLength = wordListString.length;
	
	const UniChar *list_chars;
	UniChar *list_buffer = NULL;
	
	jxld_CFStringPrepareUniCharBuffer((CFStringRef)wordListString, &list_chars, &list_buffer, CFRangeMake(0, (CFIndex)wordListStringLength));
	
	NSRange fullRange = NSMakeRange(0, wordListStringLength);
	__block NSUInteger blockNodeCount = 0;
	__block NSUInteger blockWordCount = 0;
	
	[wordListString enumerateSubstringsInRange:fullRange 
									   options:(NSStringEnumerationByLines | NSStringEnumerationSubstringNotRequired)
									usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
										//if (removeWhitespaceOnlySubstrings && ![substring ws_isBlankString]) {
										// substringRange does NOT include the line termination character while enclosingRange does!
										blockNodeCount += [rootNode insertWordWithUniChars:&(list_chars[substringRange.location]) 
																					length:substringRange.length];
										blockWordCount += 1;
										//}
									}];
	
	nodeCount += blockNodeCount;
	wordCount += blockWordCount;
	
	if (list_buffer != NULL) {
		free(list_buffer);
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
	self = [self init];
	
	if (self) {
		self.rootNode = [coder decodeObjectForKey:@"rootNode"];
		nodeCount = [coder decodeIntegerForKey:@"nodeCount"];
		wordCount = [coder decodeIntegerForKey:@"wordCount"];
		optionFlags = [coder decodeIntegerForKey:@"optionFlags"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{	
	[coder encodeObject:rootNode forKey:@"rootNode"];
	[coder encodeInteger:nodeCount forKey:@"nodeCount"];
	[coder encodeInteger:wordCount forKey:@"wordCount"];
	[coder encodeInteger:optionFlags forKey:@"optionFlags"];
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
	wordCount += 1;
	//NSLog(@"\n%@", [self description]);
}

- (void)insertWordWithUniChars:(const UniChar *)chars length:(CFIndex)length;
{
	nodeCount += [self.rootNode insertWordWithUniChars:chars length:length];
	wordCount += 1;
	//NSLog(@"\n%@", [self description]);
}

// This recursive helper is used by the search function above. It assumes that
// the previousRow has been filled in already.
void searchRecursive(JXTrieNode *node, 
					 UniChar prevLetter, UniChar thisLetter, 
					 UniChar *word_chars, CFIndex columns, 
					 CFIndex *penultimateRow, CFIndex *previousRow, 
					 UniChar *result_chars, CFIndex row_index, 
					 NSMutableArray *results, 
					 CFIndex maxCost) {
	
	result_chars[row_index] = thisLetter;

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
	if (currentRow[currentRowLastIndex] <= maxCost && node.hasWord) {
		CFStringRef nodeWord = CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, result_chars, row_index+1, kCFAllocatorNull);
		[results addObject:[JXTrieResult resultWithWord:(NSString *)nodeWord 
											andDistance:currentRow[currentRowLastIndex]]];
		CFRelease(nodeWord);
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
			JXTrieNode *nextNode = (JXTrieNode *)CFDictionaryGetValue(node.children, (void *)nextLetter);
			searchRecursive(nextNode, 
							thisLetter, nextLetter, 
							word_chars, columns, 
							previousRow, currentRow, 
							result_chars, row_index+1, 
							results, 
							maxCost);
		}
	}
	
	free(currentRow);
}

NSMutableArray * searchCore(JXTrieNode *rootNode, 
							const UniChar *string_chars, CFIndex string_length, 
							NSUInteger maxCost) {
	// build first row
    CFIndex currentRowSize = string_length + 1;
	CFIndex currentRow[currentRowSize];
	for (CFIndex k = 0; k < currentRowSize; k++) {
		currentRow[k] = k;
	}
	
	NSMutableArray *results = [NSMutableArray array];
	
	CFMutableDictionaryRef rootNodeChildren = rootNode.children;
	
	UniChar *result_chars = malloc(string_length+maxCost * sizeof(UniChar));
	
	UniChar *keys;
	CFIndex keys_count = [rootNode children_keys:&keys];
	UniChar nextLetter;
	// recursively search each branch of the trie
	for (CFIndex i = 0; i < keys_count; i++) {
		nextLetter = keys[i];
		JXTrieNode *nextNode = (JXTrieNode *)CFDictionaryGetValue(rootNodeChildren, (void *)nextLetter);
		searchRecursive(nextNode, 
						0, nextLetter, 
						(UniChar *)string_chars, string_length+1, 
						NULL, currentRow, 
						result_chars, 0, 
						results, 
						maxCost);
	}
    
	if (result_chars != NULL)  free(result_chars);
	
    return results;
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
	
    NSMutableArray *results = searchCore(self.rootNode, string_chars, string_length, maxCost);
	
	if (string_buffer != NULL)  free(string_buffer);
	
	CFRelease(string);

	return results;
}

- (NSArray *)searchForUniChar:(const UniChar *)chars length:(CFIndex)length maximumDistance:(NSUInteger)maxCost;
{
	NSArray *results;
	
	if (optionFlags) {
		CFStringRef string = CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, chars, length, kCFAllocatorNull);
		results = [self search:(NSString *)string maximumDistance:maxCost];
		CFRelease(string);
	}
	else {
		results = searchCore(self.rootNode, chars, length, maxCost);
	}
	
	return results;
}

- (NSString *)description
{
	return [rootNode description];
}


@end
