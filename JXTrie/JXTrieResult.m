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

+ (instancetype)resultWithWord:(NSString *)word
					  distance:(NSUInteger)distance
			searchStringLength:(NSUInteger)searchStringLength
#ifdef JXTRIE_WANT_VALUE_STORAGE
						 value:(id)value
#endif
;
{
	return [[JXTrieResult alloc] initWithWord:word
									 distance:distance
						   searchStringLength:searchStringLength
#ifdef JXTRIE_WANT_VALUE_STORAGE
										value:value
#endif
			];
}

- (instancetype)init
{
	return [self initWithWord:nil
					 distance:0
		   searchStringLength:0
#ifdef JXTRIE_WANT_VALUE_STORAGE
						value:nil
#endif
			];
}

- (instancetype)initWithWord:(NSString *)word
					distance:(NSUInteger)distance
		  searchStringLength:(NSUInteger)searchStringLength
#ifdef JXTRIE_WANT_VALUE_STORAGE
					   value:(id)value
#endif
;
{
	self = [super init];
	
	if (self) {
		_word = [word copy];
		_distance = distance;
		_searchStringLength = searchStringLength;
#ifdef JXTRIE_WANT_VALUE_STORAGE
		_value = value;
#endif
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
												searchStringLength:self.searchStringLength
#ifdef JXTRIE_WANT_VALUE_STORAGE
															 value:self.value
#endif
					];
	
	return newResult;
}


- (NSString *)description
{
#ifndef JXTRIE_WANT_VALUE_STORAGE
	return [NSString stringWithFormat:@"('%@', %lu, %f)", _word, (unsigned long)_distance, self.similarity];
#else
	return [NSString stringWithFormat:@"('%@': '%@', %lu, %f)", _word, _value, (unsigned long)_distance, self.similarity];
#endif
}

@end

