//
//  JXTrieNode.h
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXTrieNode : NSObject <NSCoding> {
	NSString *word;
	CFMutableDictionaryRef _children;
	
	BOOL _cacheIsFresh;
	UniChar *_children_keys;
	CFIndex _children_keys_count;
}

@property (nonatomic, copy) NSString *word;

- (CFMutableDictionaryRef)children;
- (UniChar *)children_keys;
- (CFIndex)children_keys_count;
- (void)insertNode:(JXTrieNode *)newNode forKey:(UniChar)currentChar;

- (NSUInteger)insertWord:(NSString *)newWord;

- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)descriptionWithChildren:(BOOL)describeChildren;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level describeChildren:(BOOL)describeChildren;

@end
