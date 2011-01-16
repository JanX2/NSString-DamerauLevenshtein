//
//  JXTrieNode.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXTrieNode.h"

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
	JXTrieNode *thisNode = nil;
	for (CFIndex i = 0; i < newWord_length; i++) {
		CFStringSetExternalCharactersNoCopy(letter, (UniChar *)&(newWord_chars[i]), 1, 1);
		thisNode = [node.children objectForKey:(NSString *)letter];
		if (thisNode == nil) {
			newNode = [[JXTrieNode new] autorelease];
			[node.children setValue:newNode forKey:(NSString *)letter];
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
	
	if (describeChildren && [children count] > 0) {
		[nodeDescription appendFormat:@"%@%@ = (\n", indentation, @"children"];
		NSArray *allKeys = [children allKeys];
		NSString *lastKey = [allKeys lastObject];
		
		for (NSString *childKey in allKeys) {
			thisDescription = JXDescriptionForObject([children objectForKey:childKey], nil, level+2);
			[nodeDescription appendFormat:@"%1$@%4$@ = {\n%2$@%1$@}%3$@\n", 
			 indentation2, 
			 thisDescription,
			 (childKey == lastKey) ? @"" : @",",
			 childKey];
		}
		
		[nodeDescription appendFormat:@"%@)\n", indentation];
	}

	return [nodeDescription autorelease];
	
}

@end
