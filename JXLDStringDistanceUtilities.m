//
//  JXLDStringDistanceUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 18.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//

#import "JXLDStringDistanceUtilities.h"

void jxld_CFStringRemoveWhitespace(CFMutableStringRef string) {
	CFIndex string_length = CFStringGetLength(string);
	
	CFCharacterSetRef characterSetWhitespaceAndNewline = CFCharacterSetGetPredefined(kCFCharacterSetWhitespaceAndNewline);
	
	CFRange result;
	CFRange range_to_search = CFRangeMake(0, string_length);
	
	while ( CFStringFindCharacterFromSet(string, 
										 characterSetWhitespaceAndNewline, 
										 range_to_search, 
										 kCFCompareBackwards, 
										 &result) ) {
		CFStringDelete(string, result);
		range_to_search.length = result.location; // We can do this safely, because we use kCFCompareBackwards
	}
}

void jxld_CFStringPreprocessWithOptions(CFMutableStringRef string, JXLDStringDistanceOptions options) {
	if (!(options & JXLDLiteralComparison)) {
		CFOptionFlags foldingOptions = 0;

		if (options & JXLDCaseInsensitiveComparison) {
			foldingOptions |= kCFCompareCaseInsensitive;
		}
		
		if (options & JXLDDiacriticInsensitiveComparison) {
			foldingOptions |= kCFCompareDiacriticInsensitive;
		}
		
		if (options & JXLDWidthInsensitiveComparison) {
			foldingOptions |= kCFCompareWidthInsensitive;
		}
		
		if (options & JXLDWhitespaceInsensitiveComparison) {
			//CFStringTransform(string, NULL, CFSTR("[:WhiteSpace:] any-remove;"), false); // This works, but is very slow
			jxld_CFStringRemoveWhitespace(string);
		}
		
		if (options & JXLDWhitespaceTrimmingComparison) {
			CFStringTrimWhitespace(string);
		}
		
		CFStringFold(string, foldingOptions, NULL);
		CFStringNormalize(string, kCFStringNormalizationFormC);
	}
}

