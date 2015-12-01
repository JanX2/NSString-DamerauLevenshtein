//
//  JXTrieNode.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import "JXTrieNode.h"

#import "JXLDStringDistanceUtilities.h"

#import "NSString+JXCodePointEnumeration.h"

NSString *JXDescriptionForObject(id object, id locale, NSUInteger indentLevel);

NSString *JXDescriptionForObject(id object, id locale, NSUInteger indentLevel)
{
	NSString *descriptionString;
	BOOL addQuotes = NO;
	
    if (object == nil)
        descriptionString = @"(nil)";
	else if ([object isKindOfClass:[NSString class]])
        descriptionString = object;
    else if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
        return [(id)object descriptionWithLocale:locale indent:indentLevel];
    else  if ([object respondsToSelector:@selector(descriptionWithLocale:)])
        return [(id)object descriptionWithLocale:locale];
    else
        descriptionString = [object description];
	
	NSRange range = [descriptionString rangeOfString:@" "];
	if (range.location != NSNotFound)
		addQuotes = YES;
	
	if (addQuotes)
		return [NSString stringWithFormat:@"\"%@\"", descriptionString];
	else
        return descriptionString;
	
}

@interface JXTrieNode (Private)
- (void)setChildren:(CFMutableDictionaryRef)newChildren;
@end

@implementation JXTrieNode

//@synthesize word;
@dynamic hasWord;
@synthesize wordCount = _wordCount;

- (instancetype)init
{
	self = [super init];
	if (self) {
		//self.word = nil;
		_wordCount = 0;
		_children = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks); // keys: raw UTF32Char, values:JXTrieNode objects
		_cacheIsFresh = NO;
		_children_keys = NULL;
	}
	return self;
	
}

- (void)dealloc
{
	//self.word = nil;
	self.children = nil;
	if (_children_keys != NULL)  free(_children_keys);
}


- (instancetype)initWithCoder:(NSCoder *)coder
{		
	self = [super init];
	
	if (self) {
		//self.word = [coder decodeObjectForKey:@"word"];
		_wordCount = [coder decodeIntegerForKey:@"wordCount"];
		_children = (__bridge CFMutableDictionaryRef)[coder decodeObjectForKey:@"children"];
		_cacheIsFresh = NO;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{	
	//[coder encodeObject:word forKey:@"word"];
	[coder encodeInteger:_wordCount forKey:@"wordCount"];
	[coder encodeObject:(__bridge NSMutableDictionary *)_children forKey:@"children"]; // CHANGEME: This may not work with custom CFMutableDictionary objects
}


- (CFMutableDictionaryRef)children
{
    return _children;
}

- (void)setChildren:(CFMutableDictionaryRef)newChildren
{
    if (_children != newChildren) {
        if (newChildren != NULL)  CFRetain(newChildren);
        if (_children != NULL)  CFRelease(_children);
        _children = newChildren;
		_cacheIsFresh = NO;
    }
}

- (void)refreshChildrenCache;
{
	if (_children_keys != NULL)  free(_children_keys);
	
	_children_keys_count = CFDictionaryGetCount(_children);
	if (_children_keys_count > 0) {
		void **raw_children_keys = (void **)malloc(_children_keys_count * sizeof(void *));
		
		CFDictionaryGetKeysAndValues(_children, (const void **)raw_children_keys, NULL);
		
		_children_keys = malloc(_children_keys_count * sizeof(UTF32Char));
		for (CFIndex i = 0; i < _children_keys_count; i++) {
			_children_keys[i] = (UTF32Char)raw_children_keys[i];
		}
		
		free(raw_children_keys);
	}
	else {
		_children_keys = NULL;
	}
	
	_cacheIsFresh = YES;
}

- (CFIndex)children_keys_count;
{
	if (!_cacheIsFresh)  [self refreshChildrenCache];
	return _children_keys_count;
}

- (CFIndex)children_keys:(UTF32Char **)keys;
{
	if (!_cacheIsFresh)  [self refreshChildrenCache];
	*keys = _children_keys;
	return _children_keys_count;
}

- (void)insertNode:(JXTrieNode *)newNode forKey:(UTF32Char)currentChar;
{
	CFDictionarySetValue(_children, (void *)(intptr_t)currentChar, (__bridge const void *)(newNode));
	_cacheIsFresh = NO;
}

NS_INLINE NSUInteger insertWordWithSubRangeInto(NSString *newWord, NSRange subRange, JXTrieNode *node) {
	if (newWord == nil) {
		return NSNotFound;
	}
	
	__block NSUInteger newNodesCount = 0;
	__block JXTrieNode *currentNode = node;
	[newWord enumerateCodePointsInRange:subRange
							  optionsJX:JXCodePointEnumerationOptionsRangeNotRequired
								   usingBlock:
	 ^(UTF32Char codePoint, NSRange range, BOOL *stop) {
		 JXTrieNode *thisNode = (JXTrieNode *)CFDictionaryGetValue(currentNode.children, (void *)(intptr_t)codePoint);
		 if (thisNode == nil) {
			 JXTrieNode *newNode = [JXTrieNode new];
			 [currentNode insertNode:newNode forKey:codePoint];
			 newNodesCount += 1;
			 currentNode = newNode;
		 }
		 else {
			 currentNode = thisNode;
		 }
	 }];
	
	[currentNode incrementWordCount];

	return newNodesCount;
}

- (NSUInteger)insertWord:(NSString *)newWord;
{
	NSRange fullRange = NSMakeRange(0, newWord.length);
	NSUInteger newNodesCount = insertWordWithSubRangeInto(newWord, fullRange, self);
	
	return newNodesCount;
}

- (NSUInteger)insertWordFromString:(NSString *)newWord
					  withSubRange:(NSRange)subRange;
{
	NSUInteger newNodesCount = insertWordWithSubRangeInto(newWord, subRange, self);
	
	return newNodesCount;
}

/*
- (NSUInteger)insertWordWithUniChars:(const UniChar *)chars length:(CFIndex)length;
{
	NSUInteger newNodesCount = insertWordFromUniCharsInto(chars, length, self);
	
	return newNodesCount;
}
*/

- (BOOL)hasWord;
{
	return (_wordCount > 0);
}

- (void)incrementWordCount;
{
	_wordCount++;
}

static CFStringRef jx_CFStringCreateWithCodePoint(UTF32Char codePoint)
{
	UniChar surrogates[2];
	Boolean isSurrogatePair = CFStringGetSurrogatePairForLongCharacter(codePoint, (UniChar *)&surrogates);
	const CFIndex validSurrogatesSize = (isSurrogatePair) ? sizeof(surrogates) : sizeof(UniChar);
	
	CFStringRef string = CFStringCreateWithBytes(kCFAllocatorDefault,
												 (const UInt8 *)&surrogates,
												 validSurrogatesSize,
												 kCFStringEncodingUTF16,
												 false);
	
	return string;
}

- (NSString *)description
{
	return [self descriptionWithLocale:nil indent:0 describeChildren:YES];
}

- (NSString *)descriptionWithChildren:(BOOL)describeChildren;
{
	return [self descriptionWithLocale:nil indent:0 describeChildren:describeChildren];
}

- (NSString *)descriptionWithLocale:(id)locale;
{
	return [self descriptionWithLocale:locale indent:0 describeChildren:YES];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
{
	return [self descriptionWithLocale:locale indent:level describeChildren:YES];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level describeChildren:(BOOL)describeChildren;
{
	NSMutableString *nodeDescription = [[NSMutableString alloc] init];
	
	size_t indentationDepth = (level+1) * 4;
	size_t indentationDepth2 = (level+2) * 4;
	
	char indentation_chars[indentationDepth2+1];
	memset(indentation_chars, ' ', indentationDepth2);
	indentation_chars[indentationDepth2] = '\0';
	
	NSString *indentation = [@"" stringByPaddingToLength:indentationDepth withString:@" " startingAtIndex:0];
	NSString *indentation2 = [@"" stringByPaddingToLength:indentationDepth2 withString:@" " startingAtIndex:0];
	
	NSString *thisDescription;
	
#if 0
	thisDescription = JXDescriptionForObject(self.word, nil, level+1);

	[nodeDescription appendFormat:
	 @"%@word = %@;\n", 
	 indentation, 
	 thisDescription
	 ];
#else
	NSUInteger wordCount = self.wordCount;
	thisDescription = (wordCount > 0) ? @"YES" : @"NO";
	
	[nodeDescription appendFormat:
	 @"%@word = %@ (%lu);\n", 
	 indentation, 
	 thisDescription,
	 (unsigned long)wordCount
	 ];
#endif
	
	CFIndex keys_count = self.children_keys_count;
	if (describeChildren && keys_count > 0) {
		[nodeDescription appendString:indentation];
		[nodeDescription appendString:@"children"];
		[nodeDescription appendString:@" = (\n"];

		UTF32Char this_codePoint;
		CFIndex last_index = _children_keys_count-1;
		// recursively search each branch of the trie
		for (CFIndex i = 0; i < keys_count; i++) {
			this_codePoint = _children_keys[i];
			JXTrieNode *currentNode = CFDictionaryGetValue(_children, (void *)(intptr_t)this_codePoint);
			thisDescription = JXDescriptionForObject(currentNode, nil, level+2);
			[nodeDescription appendString:indentation2];
			[nodeDescription appendString:CFBridgingRelease(jx_CFStringCreateWithCodePoint(this_codePoint))];
			[nodeDescription appendString:@" = {\n"];
			[nodeDescription appendString:thisDescription];
			[nodeDescription appendString:indentation2];
			[nodeDescription appendString:@"}"];
			[nodeDescription appendString:(i == last_index) ? @"" : @","];
			[nodeDescription appendString:@"\n"];
		}
		
		[nodeDescription appendString:indentation];
		[nodeDescription appendString:@")\n"];
	}

	return nodeDescription;
	
}

@end
