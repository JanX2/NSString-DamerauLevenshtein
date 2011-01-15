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
}

- (NSUInteger)count;

- (void)insertWord:(NSString *)newWord;

@end