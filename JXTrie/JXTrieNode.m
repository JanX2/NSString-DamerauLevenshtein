//
//  JXTrieNode.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXTrieNode.h"


@implementation JXTrieNode

@synthesize word;
@synthesize children;

- (id)init
{
	self = [super init];
	if (self) {
		self.word = nil;
		self.children = [NSMutableDictionary dictionary];
	}
	return self;
	
}

- (void)dealloc
{
	self.word = nil;
	self.children = nil;

	[super dealloc];
}


- (NSUInteger)insertWord:(NSString *)newWord;
{
	NSUInteger newNodesCount = 0;
	CFIndex newWord_length = CFStringGetLength((CFStringRef)newWord);
	
	// Prepare fast access to chars.
	const UniChar *newWord_chars;
	UniChar *newWord_buffer = NULL;
	UniChar currentChar;
	CFMutableStringRef letter = CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault, &currentChar, 1, 1, kCFAllocatorNull);
	
	newWord_chars = CFStringGetCharactersPtr((CFStringRef)newWord);
	if (newWord_chars == NULL) {
		// Fallback in case CFStringGetCharactersPtr() didn’t work. 
		newWord_buffer = malloc(newWord_length * sizeof(UniChar));
		CFStringGetCharacters((CFStringRef)newWord, CFRangeMake(0, newWord_length), newWord_buffer);
		newWord_chars = newWord_buffer;
	}
	
	JXTrieNode *node = self;
	JXTrieNode *newNode = nil;
	for (CFIndex i = 0; i < newWord_length; i++) {
		CFStringSetExternalCharactersNoCopy(letter, (UniChar *)&(newWord_chars[i]), 1, 1);
		if ([node.children objectForKey:(NSString *)letter] == nil) {
			newNode = [JXTrieNode new];
			newNodesCount += 1;
			[node.children setValue:newNode forKey:(NSString *)letter];
			[newNode release];
		}
		node = [node.children objectForKey:(NSString *)letter];
	}
	
	node.word = newWord;
	
	if (newWord_buffer != NULL) {
		free(newWord_buffer);
	}
	
	return newNodesCount;
}

@end
