//
//  JXTrieNode.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTrieNode : NSObject <NSCoding> {
	NSUInteger _wordCount;
	CFMutableDictionaryRef _children;
	
	BOOL _cacheIsFresh;
	UTF32Char *_children_keys;
	CFIndex _children_keys_count;
}

//@property (nonatomic, copy) NSString *word;
@property (nonatomic, readonly) BOOL hasWord;
@property (readonly) NSUInteger wordCount;

@property (nonatomic, readonly) CFMutableDictionaryRef children CF_RETURNS_NOT_RETAINED;
@property (nonatomic, readonly) CFIndex children_keys_count;
- (CFIndex)children_keys:(UTF32Char **)keys;
- (void)insertNode:(JXTrieNode *)newNode forKey:(UTF32Char)currentChar;

- (NSUInteger)insertWord:(NSString *)newWord;
- (NSUInteger)insertWordFromString:(NSString *)newWord
					  withSubRange:(NSRange)subRange;
//- (NSUInteger)insertWordWithUniChars:(const UniChar *)chars length:(CFIndex)length;

- (void)incrementWordCount;

- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)descriptionWithChildren:(BOOL)describeChildren;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level describeChildren:(BOOL)describeChildren;

@end
