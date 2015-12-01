//
//  JXLDStringDistanceUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 18.01.11.
//  Copyright 2011-2015 geheimwerk.de. All rights reserved.
//

#import "JXLDStringDistanceUtilities.h"

#define USE_BACKWARD_SEARCH	0 // Backward search has been used for a long time, because of its simpler implementation.

CF_INLINE void updateSearchRangeAfterModification(CFRange * const search_range_p, const CFRange result_range, const CFIndex replacement_length) {
	const CFIndex old_location = search_range_p->location;
	const CFIndex new_location = result_range.location + replacement_length;
	const CFIndex location_change = old_location - new_location; // usually negative
	const CFIndex length_change = replacement_length - result_range.length; // usually negative
	search_range_p->location = new_location;
	search_range_p->length += location_change + length_change;
}

CF_INLINE void jxld_CFStringDeleteCharactersFromSet(CFMutableStringRef string, CFCharacterSetRef characterSet) {
	CFIndex string_length = CFStringGetLength(string);
	
	CFRange result_range;
	CFRange search_range = CFRangeMake(0, string_length);
	
#if USE_BACKWARD_SEARCH
	while ( CFStringFindCharacterFromSet(string,
										 characterSet,
										 search_range,
										 kCFCompareBackwards,
										 &result_range) ) {
		CFStringDelete(string, result_range);
		search_range.length = result_range.location; // We can do this safely, because we use kCFCompareBackwards
	}
#else
	const CFIndex replacement_length = 0;
	
	while ( CFStringFindCharacterFromSet(string,
										 characterSet,
										 search_range,
										 0,
										 &result_range) ) {
		CFStringDelete(string, result_range);
		updateSearchRangeAfterModification(&search_range, result_range, replacement_length);
	}
#endif
}

CF_INLINE void jxld_CFStringReplaceCharactersFromSet(CFMutableStringRef string, CFCharacterSetRef characterSet, CFStringRef replacement) {
	// We may be able to optimize this function by directly manipulating a UniChar buffer.
	CFIndex string_length = CFStringGetLength(string);
	
	CFRange result_range;
	CFRange search_range = CFRangeMake(0, string_length);
	
#if USE_BACKWARD_SEARCH
	while ( CFStringFindCharacterFromSet(string,
										 characterSet,
										 search_range,
										 kCFCompareBackwards,
										 &result_range) ) {
		CFStringReplace(string, result_range, replacement);
		search_range.length = result_range.location; // We can do this safely, because we use kCFCompareBackwards
	}
#else
	CFIndex replacement_length = CFStringGetLength(replacement);
	
	while ( CFStringFindCharacterFromSet(string,
										 characterSet,
										 search_range,
										 0,
										 &result_range) ) {
		CFStringReplace(string, result_range, replacement);
		updateSearchRangeAfterModification(&search_range, result_range, replacement_length);
	}
#endif
}

void jxld_CFStringRemoveWhitespace(CFMutableStringRef string) {
	CFCharacterSetRef characterSetWhitespaceAndNewline = CFCharacterSetGetPredefined(kCFCharacterSetWhitespaceAndNewline);
	
	jxld_CFStringDeleteCharactersFromSet(string, characterSetWhitespaceAndNewline);
}

void jxld_CFStringReplaceDelimitersWithSpace(CFMutableStringRef string) {
	static CFCharacterSetRef delimitersCharacterSet = nil;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		delimitersCharacterSet = CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, CFSTR("_-"));
	});
	
	CFStringRef replacement = CFSTR(" ");
    jxld_CFStringReplaceCharactersInSet(string, delimitersCharacterSet, replacement);
}

void jxld_CFStringStraightenQuotes(CFMutableStringRef string) {
	CFStringRef replacement;
	
	static CFCharacterSetRef singleQuotesCharacterSet = nil;
	static CFCharacterSetRef doubleQuotesCharacterSet = nil;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		singleQuotesCharacterSet = CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, CFSTR("‘’❯❮❛❜›‹‚‛❟"));
		doubleQuotesCharacterSet = CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, CFSTR("“”„‟＂〟〞〝❝❞»«❠"));
	});
	
	replacement = CFSTR("\"");
    jxld_CFStringReplaceCharactersInSet(string, doubleQuotesCharacterSet, replacement);
	
	replacement = CFSTR("\'");
    jxld_CFStringReplaceCharactersInSet(string, singleQuotesCharacterSet, replacement);
}

void jxld_CFStringReplaceCharactersInSet(CFMutableStringRef string, CFCharacterSetRef delimitersCharacterSet, CFStringRef replacement) {
	jxld_CFStringReplaceCharactersFromSet(string, delimitersCharacterSet, replacement);
}

void jxld_CFStringPreprocessWithOptions(CFMutableStringRef string, JXLDStringDistanceOptions options) {
	if (!(options & JXLDLiteralComparison)) {
		CFStringCompareFlags foldingOptions = 0;

		if (options & JXLDCaseInsensitiveComparison) {
			foldingOptions |= kCFCompareCaseInsensitive;
		}
		
		if (options & JXLDDiacriticInsensitiveComparison) {
			foldingOptions |= kCFCompareDiacriticInsensitive;
		}
		
		if (options & JXLDWidthInsensitiveComparison) {
			foldingOptions |= kCFCompareWidthInsensitive;
		}
		
		if (options & JXLDDelimiterInsensitiveComparison) {
			jxld_CFStringReplaceDelimitersWithSpace(string);
		}
		
		if (options & JXLDQuoteTypeInsensitiveComparison) {
			jxld_CFStringStraightenQuotes(string);
		}
		
		if (options & JXLDWhitespaceInsensitiveComparison) {
			//CFStringTransform(string, NULL, CFSTR("[:WhiteSpace:] any-remove;"), false); // This works, but is very slow.
			jxld_CFStringRemoveWhitespace(string);
		}
		
		if (options & JXLDWhitespaceTrimmingComparison) {
			CFStringTrimWhitespace(string);
		}
		
		CFStringFold(string, foldingOptions, NULL);
		CFStringNormalize(string, kCFStringNormalizationFormC);
	}
}

float jxld_normalizeDistance(NSUInteger length1, NSUInteger length2, float maxDistance, NSUInteger (^levensteinDistanceBlock)(void)) {
	float normalizedDistance = 0.0f;
	
	NSUInteger longStringLength = MAX(length1, length2);
	if (maxDistance <= 1.0f) {
		NSUInteger shortStringLength = MIN(length1, length2);
		
		NSUInteger minPossibleDistance = longStringLength - shortStringLength;
		float minPossibleNormalizedDistance = (float)minPossibleDistance/longStringLength;
		if (minPossibleNormalizedDistance >= maxDistance) {
			return minPossibleNormalizedDistance;
		}
	}
	
	if (longStringLength > 0) {
		NSUInteger levensteinDistance = levensteinDistanceBlock();
		normalizedDistance = (float)levensteinDistance/longStringLength;
	}
	
	return normalizedDistance;
}
