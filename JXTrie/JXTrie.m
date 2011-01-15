//
//  JXTrie.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXTrie.h"

#import "JXTrieNode.h"


@interface JXTrie ()
@property (nonatomic, retain) JXTrieNode *rootNode;
@end

@implementation JXTrie

@synthesize rootNode;

- (id)init
{
	self = [super init];
	if (self) {
		self.rootNode = [JXTrieNode new];
		nodeCount = 0;
	}
	return self;
	
}

- (void)dealloc
{
	self.rootNode = nil;
	[super dealloc];
}


- (NSUInteger)count;
{
	return nodeCount;
}


- (void)insertWord:(NSString *)newWord;
{
	nodeCount += [self.rootNode insertWord:newWord];
}

@end