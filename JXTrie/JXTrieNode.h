//
//  JXTrieNode.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTrieNode : NSObject <NSCoding> {
	//NSString *word;
	BOOL _hasWord;
	CFMutableDictionaryRef _children;
	
	BOOL _cacheIsFresh;
	UniChar *_children_keys;
	CFIndex _children_keys_count;
}

//@property (nonatomic, copy) NSString *word;
@property (nonatomic, readwrite) BOOL hasWord;

- (CFMutableDictionaryRef)children;
- (CFIndex)children_keys_count;
- (CFIndex)children_keys:(UniChar **)keys;
- (void)insertNode:(JXTrieNode *)newNode forKey:(UniChar)currentChar;

- (NSUInteger)insertWord:(NSString *)newWord;
- (NSUInteger)insertWordWithUniChars:(const UniChar *)chars length:(CFIndex)length;

- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)descriptionWithChildren:(BOOL)describeChildren;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level describeChildren:(BOOL)describeChildren;

@end
