//
//  JXTrie.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXTrieResult.h"

@class JXTrieNode;

@interface JXTrie : NSObject {
	JXTrieNode *rootNode;
	NSUInteger nodeCount;
	NSUInteger wordCount;
}

- (NSUInteger)nodeCount;
- (NSUInteger)count;

+ (id)trieWithStrings:(NSArray *)wordList;
- (id)initWithStrings:(NSArray *)wordList;

- (void)insertWord:(NSString *)newWord;

// The search method returns an NSArray of JXTrieResult objects for all words that are less than the given maximum distance from the target word
- (NSArray *)search:(NSString *)word maximumDistance:(NSUInteger)maxCost;

@end