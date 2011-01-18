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

#import "JXLDStringDistanceUtilities.h"


@implementation NSString (DamerauLevenshtein)

- (NSUInteger)distanceFromString:(NSString *)comparisonString;
{
	return [self distanceFromString:comparisonString options:0];
}

- (NSUInteger)distanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
#define string1CharacterAtIndex(A)	string1_chars[(A)]
#define string2CharacterAtIndex(A)	string2_chars[(A)]
	
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
		jxld_CFStringPreprocessWithOptions(string1, options);
		jxld_CFStringPreprocessWithOptions(string2, options);

		// The string lengths may change during pre-processing
		n = CFStringGetLength(string1);
		m = CFStringGetLength(string2);

		// Step 1b
		CFIndex k, i, j, cost, * d;
		
		// Prepare access to chars array for string1
		const UniChar *string1_chars;
		UniChar *string1_buffer = NULL;
		
		string1_chars = CFStringGetCharactersPtr(string1);
		if (string1_chars == NULL) {
			string1_buffer = malloc(n * sizeof(UniChar));
			CFStringGetCharacters(string1, CFRangeMake(0, n), string1_buffer);
			string1_chars = string1_buffer;
		}
		
		// Prepare access to chars array for string2
		const UniChar *string2_chars;
		UniChar *string2_buffer = NULL;
		
		string2_chars = CFStringGetCharactersPtr(string2);
		if (string2_chars == NULL) {
			string2_buffer = malloc(m * sizeof(UniChar));
			CFStringGetCharacters(string2, CFRangeMake(0, m), string2_buffer);
			string2_chars = string2_buffer;
		}
		
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
				// This conditional adds Damerau transposition to the Levenshtein distance
				if (i > 1 && j > 1 
					&& string1CharacterAtIndex(i-1) == string2CharacterAtIndex(j-2) 
					&& string1CharacterAtIndex(i-2) == string2CharacterAtIndex(j-1) )
				{
					d[ j * n + i ] = MIN(d[ j * n + i ],
										d[ (j - 2) * n + i - 2 ] + cost );
				}
#endif
			}
		}
		
		distance = d[ n * m - 1 ];
		
		free( d );
		
		if (string1_buffer != NULL) free(string1_buffer);
		if (string2_buffer != NULL) free(string2_buffer);
		
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

- (float)similarityToString:(NSString *)comparisonString;
{
	return (1.0f - [self normalizedDistanceFromString:comparisonString options:0]);
}

- (float)similarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
	return (1.0f - [self normalizedDistanceFromString:comparisonString options:options]);
}

@end
