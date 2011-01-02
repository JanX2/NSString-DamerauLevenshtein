//
//  NSString+DamerauLevenshtein.m
//  DamerauLevenshtein
//
//  Created by Jan on 02.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//
//  MIT License. See NSString+DamerauLevenshtein.h for details. 

//  Based on a code snippet by Wandering Mango:
//	http://weblog.wanderingmango.com/articles/14/fuzzy-string-matching-and-the-principle-of-pleasant-surprises

#import "NSString+DamerauLevenshtein.h"

// Return the minimum of a, b and c - used by distanceFromString:options:
CF_INLINE CFIndex smallestCFIndex(CFIndex a, CFIndex b, CFIndex c) {
	CFIndex min = a;
	if ( b < min )
		min = b;
	
	if ( c < min )
		min = c;
	
	return min;
}


@implementation NSString (DamerauLevenshtein)

- (NSUInteger)distanceFromString:(NSString *)comparisonString;
{
	return [self distanceFromString:comparisonString options:0];
}

- (NSUInteger)distanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
#define string1CharacterAtIndex(A)	CFStringGetCharacterFromInlineBuffer(&string1_inlineBuffer, (A))
#define string2CharacterAtIndex(A)	CFStringGetCharacterFromInlineBuffer(&string2_inlineBuffer, (A))
	
	// This implementation can be improved further if execution speed or memory constraints should ever pose a problem:
	// http://en.wikipedia.org/wiki/Levenstein_Distance#Possible_improvements
	
	CFMutableStringRef string1 = (CFMutableStringRef)[self mutableCopy];
	CFMutableStringRef string2 = (CFMutableStringRef)[comparisonString mutableCopy];
	
	// Step 1a (Steps follow description at http://www.merriampark.com/ld.htm )
	CFIndex n, m;
	n = CFStringGetLength(string1);
	m = CFStringGetLength(string2);
	
	CFIndex distance = kCFNotFound;
	
	if (n == 0) {
		distance = m;
	}
	
	if (m == 0) {
		distance = n;
	}
	
	if (distance == kCFNotFound) {
		
		// Processing options and pre-processing the strings accordingly 
		if (!(options & JXLDLiteralComparison)) {
			CFStringNormalize(string1, kCFStringNormalizationFormD);
			CFStringNormalize(string2, kCFStringNormalizationFormD);
		}
		
		if (options & JXLDWhitespaceInsensitiveComparison) {
			NSArray *string1Array = [(NSString *)string1 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *string1WithoutWhitespace = [string1Array componentsJoinedByString:@""];
			CFRelease(string1);
			string1 = (CFMutableStringRef)[string1WithoutWhitespace mutableCopy];
			
			NSArray *string2Array = [(NSString *)string2 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *string2WithoutWhitespace = [string2Array componentsJoinedByString:@""];
			CFRelease(string2);
			string2 = (CFMutableStringRef)[string2WithoutWhitespace mutableCopy];
		}
		
		if (options & JXLDWhitespaceTrimmingComparison) {
			CFStringTrimWhitespace(string1);
			CFStringTrimWhitespace(string2);
		}
		
		if (options & JXLDCaseInsensitiveComparison) {
			CFLocaleRef userLocale = CFLocaleCopyCurrent();
			CFStringLowercase(string1, userLocale);
			CFStringLowercase(string2, userLocale);
			CFRelease(userLocale);
		}
		
		if (options & JXLDDiacriticInsensitiveComparison) {
			CFStringTransform(string1, NULL, kCFStringTransformStripDiacritics, false);
			CFStringTransform(string2, NULL, kCFStringTransformStripDiacritics, false);
		}
		
		if (options & JXLDWidthInsensitiveComparison) {
			CFStringTransform(string1, NULL, kCFStringTransformFullwidthHalfwidth, false);
			CFStringTransform(string2, NULL, kCFStringTransformFullwidthHalfwidth, false);
		}

		// The string lengths may change during pre-processing
		n = CFStringGetLength(string1);
		m = CFStringGetLength(string2);

		// Step 1b
		CFIndex k, i, j, cost, * d;
		
		CFStringInlineBuffer string1_inlineBuffer, string2_inlineBuffer;
		CFStringInitInlineBuffer(string1, &string1_inlineBuffer, CFRangeMake(0, n));
		CFStringInitInlineBuffer(string2, &string2_inlineBuffer, CFRangeMake(0, m));
		
		n++;
		m++;
		
		d = malloc( sizeof(CFIndex) * m * n );
		
		// Step 2
		for ( k = 0; k < n; k++) {
			d[k] = k;
		}
		
		for ( k = 0; k < m; k++) {
			d[ k * n ] = k;
		}
		
		// Step 3 and 4
		for ( i = 1; i < n; i++ ) {
			for ( j = 1; j < m; j++ ) {
				
				// Step 5
				if ( string1CharacterAtIndex(i-1) == string2CharacterAtIndex(j-1) ) {
					cost = 0;
				}
				else {
					cost = 1;
				}
				
				// Step 6
				d[ j * n + i ] = smallestCFIndex(d[ (j - 1) * n + i ] + 1,
												 d[ j * n + i - 1 ] +  1,
												 d[ (j - 1) * n + i - 1 ] + cost );
				
#ifndef DISABLE_DAMERAU_TRANSPOSITION
				// This conditional adds Damerau transposition to Levenshtein distance
				if (i > 1 && j > 1 
					&& string1CharacterAtIndex(i-1) == string2CharacterAtIndex(j-2) 
					&& string1CharacterAtIndex(i-2) == string2CharacterAtIndex(j-1) )
				{
					d[ j * n + i] = MIN(d[ j * n + i ],
										d[ (j - 2) * n + i - 2 ] + cost );
				}
#endif
			}
		}
		
		distance = d[ n * m - 1 ];
		
		free( d );
		
	}
	
	CFRelease(string1);
	CFRelease(string2);
	
	return (NSUInteger)distance;
	
#undef string1CharacterAtIndex
#undef string2CharacterAtIndex
}

- (float)normalizedDistanceFromString:(NSString *)comparisonString;
{
	return [self normalizedDistanceFromString:comparisonString options:0];
}

- (float)normalizedDistanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
	NSUInteger levensteinDistance = [self distanceFromString:comparisonString options:options];
	NSUInteger reference = MAX(self.length, comparisonString.length);
	
	return (float)levensteinDistance/reference;
}

@end
