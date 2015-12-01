//
//  JXTrieResult.m
//  Damerau-Levenshtein
//
//  Created by Jan on 15.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import "JXTrieResult.h"

#import "JXLDStringDistanceUtilities.h"


@implementation JXTrieResult

+ (instancetype)resultWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength;
{
	return [[JXTrieResult alloc] initWithWord:word distance:distance searchStringLength:searchStringLength];
}

- (instancetype)init
{
	return [self initWithWord:nil distance:0 searchStringLength:0];
}

- (instancetype)initWithWord:(NSString *)word distance:(NSUInteger)distance searchStringLength:(NSUInteger)searchStringLength;
{
	self = [super init];
	
	if (self) {
		_word = [word copy];
		_distance = distance;
		_searchStringLength = searchStringLength;
	}
	
	return self;
}


- (float)normalizedDistance;
{
	float normalizedDistance = jxld_normalizeDistance(_word.length, _searchStringLength, 1.0f, ^NSUInteger{
		return _distance;
	});
	
	return normalizedDistance;
}

- (float)similarity;
{
	return (1.0f - self.normalizedDistance);
}


- (id)copyWithZone:(NSZone *)zone
{
	id newResult = [[[self class] allocWithZone:zone] initWithWord:self.word
														  distance:self.distance
												searchStringLength:self.searchStringLength];
	
	return newResult;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"('%@', %lu, %f)", _word, (unsigned long)_distance, self.similarity];
}

@end

