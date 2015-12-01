//
//  JXTrieResult.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import "JXTrieResult.h"



@implementation JXTrieResult

+ (instancetype)resultWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;
{
	return [[JXTrieResult alloc] initWithWord:aWord andDistance:aDistance];
}

- (instancetype)init
{
	return [self initWithWord:nil andDistance:0];
}

- (instancetype)initWithWord:(NSString *)aWord andDistance:(NSUInteger)aDistance;
{
	self = [super init];
	
	if (self) {
		_word = aWord;
		_distance = aDistance;
	}
	
	return self;
	
}


- (id)copyWithZone:(NSZone *)zone
{
	id newResult = [[[self class] allocWithZone:zone] initWithWord:self.word 
													   andDistance:self.distance];
	
	return newResult;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"('%@', %lu)", _word, (unsigned long)_distance];
}

@end

