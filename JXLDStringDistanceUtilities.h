//
//  JXLDStringDistanceUtilities.h
//  Damerau-Levenshtein
//
//  Created by Jan on 18.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXLDStringDistance.h"


// Return the minimum of a, b and c
CF_INLINE CFIndex jxld_smallestCFIndex(CFIndex a, CFIndex b, CFIndex c) {
	return MIN(MIN(a, b), c);
}

CF_INLINE void jxld_CFStringPrepareUniCharBuffer(CFStringRef string, const UniChar **string_chars, UniChar **string_buffer, CFRange string_range) {
	*string_chars = CFStringGetCharactersPtr(string);
	if (*string_chars == NULL) {
		// Fallback in case CFStringGetCharactersPtr() didn’t work. 
		*string_buffer = malloc(string_range.length * sizeof(UniChar));
		CFStringGetCharacters(string, string_range, *string_buffer);
		*string_chars = *string_buffer;
	}
}

void jxld_CFStringRemoveWhitespace(CFMutableStringRef string);
void jxld_CFStringReplaceCharactersInSet(CFMutableStringRef string, CFCharacterSetRef delimitersCharacterSet, CFStringRef replacement);
void jxld_CFStringReplaceDelimitersWithSpace(CFMutableStringRef string);
void jxld_CFStringStraightenQuotes(CFMutableStringRef string);

void jxld_CFStringPreprocessWithOptions(CFMutableStringRef string, JXLDStringDistanceOptions options);

float jxld_normalizeDistance(NSUInteger length1, NSUInteger length2, float maxDistance, NSUInteger (^levensteinDistanceBlock)(void));
