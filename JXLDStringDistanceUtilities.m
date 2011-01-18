//
//  JXLDStringDistanceUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 18.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import "JXLDStringDistanceUtilities.h"


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
			CFStringTransform(string, NULL, CFSTR("[:WhiteSpace:] any-remove;"), false);
		}
		
		if (options & JXLDWhitespaceTrimmingComparison) {
			CFStringTrimWhitespace(string);
		}
		
		CFStringNormalize(string, kCFStringNormalizationFormD);
		CFStringFold(string, foldingOptions, NULL);
	}
}

