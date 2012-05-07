//
//  JXTrieResult.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//

#import "JXTrieResult.h"


@implementation JXTrieResult

@synthesize word;
@synthesize distance;

+ (id)resultWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;
{
	return [[[JXTrieResult alloc] initWithWord:aWord andDistance:aDistance] autorelease];
}

- (id)initWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;
{
	self = [super init];
	if (self) {
		self.word = aWord;
		self.distance = aDistance;
	}
	return self;
	
}

- (void)dealloc
{
	self.word = nil;

	[super dealloc];
}


- (id)copyWithZone:(NSZone *)zone
{
	id newResult = [[[self class] allocWithZone:zone] initWithWord:self.word 
													   andDistance:self.distance];
	
	return newResult;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"('%@', %lu)", word, (unsigned long)distance];
}

@end

