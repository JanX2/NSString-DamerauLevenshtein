//
//  NSString+DamerauLevenshtein.m
//  DamerauLevenshtein
//
//  Created by Jan on 02.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//
//  MIT License. See NSString+DamerauLevenshtein.h for details. 

//  Based on a code snippet by Wandering Mango:
//	http://weblog.wanderingmango.com/articles/14/fuzzy-string-matching-and-the-principle-of-pleasant-surprises

#import "NSString+DamerauLevenshtein.h"

#import "JXLDStringDistanceUtilities.h"


@implementation NSString (DamerauLevenshtein)

CFIndex levensteinStringDistance(CFStringRef string1, CFStringRef string2);
CFIndex levensteinUniCharDistance(const UniChar *string1_chars, CFIndex n, const UniChar *string2_chars, CFIndex m);
CFIndex levensteinUniCharDistanceCore(const UniChar *string1_chars, CFIndex n, const UniChar *string2_chars, CFIndex m);

int tokenRanges(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges);
CFIndex valueWords(CFStringRef string1, const UniChar *string1_chars, CFIndex n, CFStringRef string2, const UniChar *string2_chars, CFIndex m);
float semanticStringDistance(CFStringRef string1, CFStringRef string2);

- (NSUInteger)distanceFromString:(NSString *)comparisonString;
{
	return [self distanceFromString:comparisonString options:0];
}

- (NSUInteger)distanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
	CFStringRef string1, string2;
	
	CFMutableStringRef string1_mutable = NULL;
	CFMutableStringRef string2_mutable = NULL;
	
	if (options & JXLDLiteralComparison) {
		string1 = (CFStringRef)self;
		string2 = (CFStringRef)comparisonString;
	}
	else {
		string1_mutable = (CFMutableStringRef)[self mutableCopy];
		string2_mutable = (CFMutableStringRef)[comparisonString mutableCopy];
		
		// Processing options and pre-processing the strings accordingly 
		// The string lengths may change during pre-processing
		jxld_CFStringPreprocessWithOptions(string1_mutable, options);
		jxld_CFStringPreprocessWithOptions(string2_mutable, options);

		string1 = (CFStringRef)string1_mutable;
		string2 = (CFStringRef)string2_mutable;
	}
	
	NSUInteger distance = levensteinStringDistance(string1, string2);
	
	if (string1_mutable != NULL)  CFRelease(string1_mutable);
	if (string2_mutable != NULL)  CFRelease(string2_mutable);
	
	return distance;
}

CFIndex levensteinStringDistance(CFStringRef string1, CFStringRef string2) {
	// This implementation can be improved further if execution speed or memory constraints should ever pose a problem:
	// http://en.wikipedia.org/wiki/Levenstein_Distance#Possible_improvements
	
	// Step 1a (Steps follow description at http://www.merriampark.com/ld.htm )
	CFIndex n, m;
	n = CFStringGetLength(string1);
	m = CFStringGetLength(string2);
	
	UniChar *string1_buffer = NULL;
	UniChar *string2_buffer = NULL;

	CFIndex distance = kCFNotFound;
	
	// This loop is here just so we don’t have to use goto
	while (distance == kCFNotFound) {
		
		if (n == 0) {
			distance = m;
			break;
		}
		
		if (m == 0) {
			distance = n;
			break;
		}		
		
		// Prepare access to chars array for string1
		const UniChar *string1_chars;
		jxld_CFStringPrepareUniCharBuffer(string1, &string1_chars, &string1_buffer, CFRangeMake(0, n));
		
		// Prepare access to chars array for string2
		const UniChar *string2_chars;
		jxld_CFStringPrepareUniCharBuffer(string2, &string2_chars, &string2_buffer, CFRangeMake(0, m));
		
		distance = levensteinUniCharDistanceCore(string1_chars, n, string2_chars, m);
	}
	
	if (string1_buffer != NULL) free(string1_buffer);
	if (string2_buffer != NULL) free(string2_buffer);
	
	return distance;
}

CFIndex levensteinUniCharDistanceCore(const UniChar *string1_chars, CFIndex n, const UniChar *string2_chars, CFIndex m) {
#define string1CharacterAtIndex(A)	string1_chars[(A)]
#define string2CharacterAtIndex(A)	string2_chars[(A)]
	
	CFIndex distance = 0;
	
	// Step 1b
	// Indexes into strings string1 and string2
	CFIndex i;		// Iterates through string1
	CFIndex j;		// Iterates through string2
	
	CFIndex cost;
	
	// Ignore common prefix (reducing memory footprint).
	while (m > 0 && n > 0 && (*string1_chars == *string2_chars)) {
		m -= 1;
		n -= 1;
		string1_chars++;
		string2_chars++;
	}
	
	// Ignore common suffix (reducing memory footprint).
	while (m > 0 && n > 0 && (string1_chars[n-1] == string2_chars[m-1])) {
		m -= 1;
		n -= 1;
	}
	
	// This implementation is based on Chas Emerick’s Java implementation:
	// http://www.merriampark.com/ldjava.htm
	
	CFIndex *d = malloc((n+1) * sizeof(CFIndex));	// Cost array, horizontally
	CFIndex *p = malloc((n+1) * sizeof(CFIndex));	// 'previous' cost array, horizontally
	CFIndex *_d;			// Placeholder to assist in swapping p and d
	
#ifndef DISABLE_DAMERAU_TRANSPOSITION
	CFIndex *p2 = malloc((n+1) * sizeof(CFIndex));	// cost array before 'previous', horizontally
#endif
	
	// Step 2
	for (i = 0; i <= n; i++) {
		p[i] = i;
	}
	
	// Step 3 and 4
	for (j = 1; j <= m; j++) {
		d[0] = j;
		
		for (i = 1; i <= n; i++) {
			// Step 5
			cost = (string1CharacterAtIndex(i-1) == string2CharacterAtIndex(j-1)) ? 0 : 1;
			
			// Step 6
			// Minimum of cell to the left+1, to the top+1, diagonally left and up +cost				
			d[i] = MIN(MIN(d[i-1]+1, p[i]+1),  p[i-1]+cost);  
			
#ifndef DISABLE_DAMERAU_TRANSPOSITION
			// This conditional adds Damerau transposition to the Levenshtein distance
			if (i > 1 && j > 1 
				&& string1CharacterAtIndex(i-1) == string2CharacterAtIndex(j-2) 
				&& string1CharacterAtIndex(i-2) == string2CharacterAtIndex(j-1) )
			{
				d[i] = MIN(d[i], p2[i-2] + cost );
			}
#endif
		}
		
		// Copy current distance counts to 'previous row' distance counts
#ifdef DISABLE_DAMERAU_TRANSPOSITION
		_d = p;
#else
		_d = p2;
		p2 = p;
#endif
		p = d;
		d = _d;
	} 
	
	// Our last action in the above loop was to switch d and p, so p now 
	// actually has the most recent cost counts
	distance = p[n];
	
	free(d);
	free(p);
#ifndef DISABLE_DAMERAU_TRANSPOSITION
	free(p2);
#endif
	
	return distance;
	
#undef string1CharacterAtIndex
#undef string2CharacterAtIndex
}

CFIndex levensteinUniCharDistance(const UniChar *string1_chars, CFIndex n, const UniChar *string2_chars, CFIndex m) {
	CFIndex distance = 0;
	
	if (n == 0) {
		distance = m;
		return distance;
	}
	
	if (m == 0) {
		distance = n;
		return distance;
	}		
	
	distance = levensteinUniCharDistanceCore(string1_chars, n, string2_chars, m);

	return distance;
}

int tokenRanges(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges) {
	int token_ranges_capacity = 4; // CHANGE To 16!
	CFRange * token_ranges = malloc(token_ranges_capacity * sizeof(CFRange));
	
	CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, tokenizerRange, tokenizerOptions, NULL);
	
	// Set tokenizer to the start of the string. 
	CFStringTokenizerTokenType mask = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
	
	CFRange tokenRange;
	int token_index = 0;
	while (mask != kCFStringTokenizerTokenNone) {
		tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
		
		if (token_ranges_capacity == token_index+1) {
			token_ranges_capacity *= 2;
			token_ranges = realloc(token_ranges, (token_ranges_capacity * sizeof(CFRange)));
		}
		
		token_ranges[token_index] = tokenRange;
		
		token_index++;
		
		mask = CFStringTokenizerAdvanceToNextToken(tokenizer);
	}
	
	CFRelease(tokenizer);
	
	*ranges = token_ranges;
	
	return token_index;
}

CFIndex valueWords(CFStringRef string1, const UniChar *string1_chars, CFIndex n, CFStringRef string2, const UniChar *string2_chars, CFIndex m) {
	CFRange *word_ranges1, *word_ranges2;
	int word_count1 = tokenRanges(string1, CFRangeMake(0, n), kCFStringTokenizerUnitWord, &word_ranges1);
	int word_count2 = tokenRanges(string2, CFRangeMake(0, m), kCFStringTokenizerUnitWord, &word_ranges2);
	
	CFIndex distance_total = 0;
	CFRange word1Range, word2Range;
	
	for (int i = 0; i < word_count1; i++) {
		word1Range = word_ranges1[i];
		
		CFIndex best_distance = m;
		
		for (int j = 0; j < word_count2; j++) {
			word2Range = word_ranges2[j];
			
			CFIndex this_distance = levensteinUniCharDistance(&(string1_chars[word1Range.location]), word1Range.length, 
													  &(string2_chars[word2Range.location]), word2Range.length);
            
			if (this_distance < best_distance)  best_distance = this_distance;
            
			if (this_distance == 0) {
				break;
			}
		}
		
        distance_total += best_distance;
	}
	
	free(word_ranges1);
	free(word_ranges2);
	
	return distance_total;
}

float semanticStringDistance(CFStringRef string1, CFStringRef string2) {
#define valuePhrase	levensteinUniCharDistanceCore
	float phrase_weight = 0.5;
	float words_weight = 1.0;
	float length_weight = -0.3;
	float min_weight = 10.0;
	float max_weight = 1.0;

	CFIndex n, m;
	n = CFStringGetLength(string1);
	m = CFStringGetLength(string2);
	
	UniChar *string1_buffer = NULL;
	UniChar *string2_buffer = NULL;
	
	float distance;
	
	// This loop is here just so we don’t have to use goto
	while (1) {
		
		if (n == 0) {
			distance = m;
			break;
		}
		
		if (m == 0) {
			distance = n;
			break;
		}		
		
		// Prepare access to chars array for string1
		const UniChar *string1_chars;
		jxld_CFStringPrepareUniCharBuffer(string1, &string1_chars, &string1_buffer, CFRangeMake(0, n));
		
		// Prepare access to chars array for string2
		const UniChar *string2_chars;
		jxld_CFStringPrepareUniCharBuffer(string2, &string2_chars, &string2_buffer, CFRangeMake(0, m));
		
		float phrase_value = (float)valuePhrase(string1_chars, n, string2_chars, m);
		float words_value = (float)valueWords(string1, string1_chars, n, string2, string2_chars, m);
		float length_value = (float)ABS(n - m);
		
		distance = (MIN(phrase_value*phrase_weight, words_value*words_weight)*min_weight
					+ MAX(phrase_value*phrase_weight, words_value*words_weight)*max_weight
					+ length_weight*length_value);
		
		break;
	}
	
	if (string1_buffer != NULL) free(string1_buffer);
	if (string2_buffer != NULL) free(string2_buffer);
	
	return distance;
}

- (float)semanticDistanceFromString:(NSString *)comparisonString;
{
	JXLDStringDistanceOptions options = JXLDDelimiterInsensitiveComparison | JXLDWhitespaceTrimmingComparison;
	
	CFStringRef string1, string2;
	
	CFMutableStringRef string1_mutable = NULL;
	CFMutableStringRef string2_mutable = NULL;
	
	if (options & JXLDLiteralComparison) {
		string1 = (CFStringRef)self;
		string2 = (CFStringRef)comparisonString;
	}
	else {
		string1_mutable = (CFMutableStringRef)[self mutableCopy];
		string2_mutable = (CFMutableStringRef)[comparisonString mutableCopy];
		
		// Processing options and pre-processing the strings accordingly 
		// The string lengths may change during pre-processing
		jxld_CFStringPreprocessWithOptions(string1_mutable, options);
		jxld_CFStringPreprocessWithOptions(string2_mutable, options);
		
		string1 = (CFStringRef)string1_mutable;
		string2 = (CFStringRef)string2_mutable;
	}
	
	float distance = semanticStringDistance(string1, string2);
	
	if (string1_mutable != NULL)  CFRelease(string1_mutable);
	if (string2_mutable != NULL)  CFRelease(string2_mutable);
	
	return distance;
}

- (float)normalizedDistanceFromString:(NSString *)comparisonString;
{
	return [self normalizedDistanceFromString:comparisonString options:0 maximumDistance:FLT_MAX];
}

- (float)normalizedDistanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
	return [self normalizedDistanceFromString:comparisonString options:options maximumDistance:FLT_MAX];
}

- (float)normalizedDistanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options maximumDistance:(float)maxDistance;
{
	float normalizedDistance = 0.0f;
	NSUInteger selfLength = self.length;
	NSUInteger comparisonStringLength = comparisonString.length;
	
	NSUInteger longStringLength = MAX(selfLength, comparisonStringLength);
	if (maxDistance <= 1.0f) {
		NSUInteger shortStringLength = MIN(selfLength, comparisonStringLength);
		
		NSUInteger minPossibleDistance = longStringLength - shortStringLength;
		float minPossibleNormalizedDistance = (float)minPossibleDistance/longStringLength;
		if (minPossibleNormalizedDistance >= maxDistance) {
			return minPossibleNormalizedDistance;
		}
	}
	
	if (longStringLength > 0) {
		NSUInteger levensteinDistance = [self distanceFromString:comparisonString options:options];
		normalizedDistance = (float)levensteinDistance/longStringLength;
	}
	
	return normalizedDistance;
}

- (float)similarityToString:(NSString *)comparisonString;
{
	return (1.0f - [self normalizedDistanceFromString:comparisonString options:0 maximumDistance:FLT_MAX]);
}

- (float)similarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
	return (1.0f - [self normalizedDistanceFromString:comparisonString options:options maximumDistance:FLT_MAX]);
}

- (float)similarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options minimumSimilarity:(float)minSimilarity;
{
	return (1.0f - [self normalizedDistanceFromString:comparisonString options:options maximumDistance:(1.0f - minSimilarity)]);
}

- (BOOL)hasSimilarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options minimumSimilarity:(float)minSimilarity;
{
	return ((1.0f - [self normalizedDistanceFromString:comparisonString options:options maximumDistance:(1.0f - minSimilarity)]) >= minSimilarity);
}

@end
