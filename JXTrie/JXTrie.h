//
//  JXTrie.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//
//  MIT License. 
//  License information is at the end of this file. 

//  Based on a code snippet by Steve Hanov:
//	http://stevehanov.ca/blog/index.php?id=114

#import <Foundation/Foundation.h>

#import "../JXLDStringDistance.h"
#import "JXTrieResult.h"

@class JXTrieNode;

@interface JXTrie : NSObject <NSCoding>

@property (nonatomic, readonly) NSUInteger nodeCount;
@property (nonatomic, readonly) NSUInteger count;

+ (instancetype)trie;
+ (instancetype)trieWithOptions:(JXLDStringDistanceOptions)options;
- (instancetype)init;
- (instancetype)initWithOptions:(JXLDStringDistanceOptions)options NS_DESIGNATED_INITIALIZER;

+ (instancetype)trieWithStrings:(NSArray *)wordList;
+ (instancetype)trieWithStrings:(NSArray *)wordList options:(JXLDStringDistanceOptions)options;
- (instancetype)initWithStrings:(NSArray *)wordList;
- (instancetype)initWithStrings:(NSArray *)wordList options:(JXLDStringDistanceOptions)options;

+ (instancetype)trieWithWordListString:(NSString *)wordListString;
+ (instancetype)trieWithWordListString:(NSString *)wordListString options:(JXLDStringDistanceOptions)options;
- (instancetype)initWithWordListString:(NSString *)wordListString;
- (instancetype)initWithWordListString:(NSString *)wordListString options:(JXLDStringDistanceOptions)options;

- (void)insertWord:(NSString *)newWord;
- (void)insertWordFromString:(NSString *)newWord
				withSubRange:(NSRange)subRange;

#ifdef JXTRIE_WANT_VALUE_STORAGE
- (void)insertValue:(id)value
			forWord:(NSString *)newWord;

- (void)insertValue:(id)value
  forWordFromString:(NSString *)newWord
	   withSubRange:(NSRange)subRange;
#endif

// The search method returns an NSArray of JXTrieResult objects for all words 
// that are at most the given maximum distance from the target word. 
- (NSArray *)search:(NSString *)word maximumDistance:(NSUInteger)maxCost;

// The array is sorted by `similarity`, if requested.
- (NSArray *)search:(NSString *)word maximumDistance:(NSUInteger)maxCost sortingResults:(BOOL)doSort;

@end

/*
 * Author: steve.hanov@gmail.com (Steve Hanov)
 * Author: jan@geheimwerk.de (Jan Weiß)
 *
 * Copyright (c) 2011-2015 geheimwerk.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

