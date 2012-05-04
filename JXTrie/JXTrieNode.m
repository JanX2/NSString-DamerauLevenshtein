//
//  JXTrieNode.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXTrieNode.h"

#import "JXLDStringDistanceUtilities.h"

NSString *JXDescriptionForObject(id object, id locale, NSUInteger indentLevel);

NSString *JXDescriptionForObject(id object, id locale, NSUInteger indentLevel)
{
	NSString *descriptionString;
	BOOL addQuotes = NO;
	
    if ([object isKindOfClass:[NSString class]])
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

@synthesize word;

- (id)init
{
	self = [super init];
	if (self) {
		self.word = nil;
		self.children = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks); // keys: raw UniChar, values:JXTrieNode objects
		_cacheIsFresh = NO;
		_children_keys = NULL;
	}
	return self;
	
}

- (void)dealloc
{
	self.word = nil;
	self.children = nil;
	if (_children_keys != NULL)  free(_children_keys);

	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder
{		
	self = [super init];
	
	if (self) {
		self.word = [coder decodeObjectForKey:@"word"];
		self.children = (CFMutableDictionaryRef)[coder decodeObjectForKey:@"children"];
		_cacheIsFresh = NO;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{	
	[coder encodeObject:word forKey:@"word"];
	[coder encodeObject:(NSMutableDictionary *)_children forKey:@"children"]; // CHANGEME: This may not work with custom CFMutableDictionary objects
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
		
		_children_keys = malloc(_children_keys_count * sizeof(UniChar));
		for (CFIndex i = 0; i < _children_keys_count; i++) {
			_children_keys[i] = (UniChar)raw_children_keys[i];
		}
		
		free(raw_children_keys);
	}
	else {
		_children_keys = NULL;
	}
	
	_cacheIsFresh = YES;
}

- (UniChar *)children_keys;
{
	if (!_cacheIsFresh)  [self refreshChildrenCache];
	return _children_keys;
}

- (CFIndex)children_keys_count;
{
	if (!_cacheIsFresh)  [self refreshChildrenCache];
	return _children_keys_count;
}

- (void)insertNode:(JXTrieNode *)newNode forKey:(UniChar)currentChar;
{
	CFDictionarySetValue(_children, (void *)currentChar, newNode);
	_cacheIsFresh = NO;
}


- (NSUInteger)insertWord:(NSString *)newWord;
{
	NSUInteger newNodesCount = 0;
	CFIndex newWord_length = CFStringGetLength((CFStringRef)newWord);
	
	// Prepare fast access to chars.
	const UniChar *newWord_chars;
	UniChar *newWord_buffer = NULL;
	
	jxld_CFStringPrepareUniCharBuffer((CFStringRef)newWord, &newWord_chars, &newWord_buffer, CFRangeMake(0, newWord_length));
	
	UniChar currentChar;
	JXTrieNode *node = self;
	JXTrieNode *newNode = nil;
	JXTrieNode *thisNode = nil;
	for (CFIndex i = 0; i < newWord_length; i++) {
		currentChar = newWord_chars[i];
		thisNode = (JXTrieNode *)CFDictionaryGetValue(node.children, (void *)currentChar);
		if (thisNode == nil) {
			newNode = [[JXTrieNode new] autorelease];
			[node insertNode:newNode forKey:currentChar];
			newNodesCount += 1;
			node = newNode;
		}
		else {
			node = thisNode;
		}
	}
	
	node.word = newWord;
	
	if (newWord_buffer != NULL) {
		free(newWord_buffer);
	}
	
	return newNodesCount;
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
	
	NSString *indentation2 = [NSString stringWithCString:(const char *)indentation_chars encoding:NSASCIIStringEncoding];
	indentation_chars[indentationDepth] = '\0';
	NSString *indentation = [NSString stringWithCString:(const char *)indentation_chars encoding:NSASCIIStringEncoding];
	
	NSString *thisDescription;
	
	thisDescription = JXDescriptionForObject(self.word, nil, level+1);

	[nodeDescription appendFormat:
	 @"%@word = %@;\n", 
	 indentation, 
	 thisDescription
	 ];
	
	CFIndex keys_count = self.children_keys_count;
	if (describeChildren && keys_count > 0) {
		[nodeDescription appendFormat:@"%@%@ = (\n", indentation, @"children"];
		
		UniChar *keys = self.children_keys;
		UniChar this_letter;
		CFIndex last_index = keys_count-1;
		// recursively search each branch of the trie
		for (CFIndex i = 0; i < keys_count; i++) {
			this_letter = keys[i];
			JXTrieNode *currentNode = CFDictionaryGetValue(_children, (void *)this_letter);
			thisDescription = JXDescriptionForObject(currentNode, nil, level+2);
			[nodeDescription appendFormat:@"%1$@%4$C = {\n%2$@%1$@}%3$@\n", 
			 indentation2, 
			 thisDescription,
			 (i == last_index) ? @"" : @",",
			 this_letter];
		}
		
		[nodeDescription appendFormat:@"%@)\n", indentation];
	}

	return [nodeDescription autorelease];
	
}

@end
