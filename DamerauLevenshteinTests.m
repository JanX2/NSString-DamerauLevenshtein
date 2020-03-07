//
//  DamerauLevenshteinTests.m
//  Damerau-Levenshtein
//
//  Created by Jan on 02.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//

#import "DamerauLevenshteinTests.h"

#import "NSString+DamerauLevenshtein.h"
#import "JXLDStringTokenUtilities.h"

// A bit hacky ;)
NSString *DamerauLevenshteinTestsLongString1;
NSString *DamerauLevenshteinTestsLongString2;


@implementation DamerauLevenshteinTests

#define LONG_STRING_EXPANSION_FACTOR	4

+ (void) initialize
{
	if ( self == [DamerauLevenshteinTests class] ) {
		NSError *error;
		
		//NSBundle *testBundle = [NSBundle bundleWithIdentifier:@"de.geheimwerk.DamerauLevenshteinTest"];
		NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
		
		NSString *a;
		NSString *b;
		
		a = [[NSString alloc] initWithContentsOfURL:[testBundle URLForResource:@"Lorem1" withExtension:@"txt"] 
																			encoding:NSUTF8StringEncoding 
																			   error:&error];
		if (!a)  NSLog(@"%@", error);
		
		b = [[NSString alloc] initWithContentsOfURL:[testBundle URLForResource:@"Lorem2" withExtension:@"txt"] 
																			encoding:NSUTF8StringEncoding 
																			   error:&error];
		if (!b)  NSLog(@"%@", error);
		
		NSMutableString *aMutable = [NSMutableString stringWithString:a];
		NSMutableString *bMutable = [NSMutableString stringWithString:b];

		for (int x = 1; x < LONG_STRING_EXPANSION_FACTOR; x++) {
			[aMutable appendString:a];
			[bMutable appendString:b];
		}
		
		DamerauLevenshteinTestsLongString1 = [aMutable copy];
		DamerauLevenshteinTestsLongString2 = [bMutable copy];		
	}
}



- (void)test_empty {
	XCTAssertEqual((NSUInteger)0, [@"" distanceFromString:@""], @"Empty test #1 failed.");

	XCTAssertEqual((NSUInteger)1, [@"" distanceFromString:@"a"], @"Empty test #2 failed.");

	XCTAssertEqual((NSUInteger)1, [@"a" distanceFromString:@""], @"Empty test #3 failed.");
}

- (void)test_simple {
	XCTAssertEqual((NSUInteger)1, [@"ab" distanceFromString:@"abc"], @"Simple insertion test failed.");

	XCTAssertEqual((NSUInteger)1, [@"ab" distanceFromString:@"a"], @"Simple deletion test failed.");

	XCTAssertEqual((NSUInteger)1, [@"ab" distanceFromString:@"az"], @"Simple substitution test failed.");

#ifndef DISABLE_DAMERAU_TRANSPOSITION
	XCTAssertEqual((NSUInteger)1, [@"ab" distanceFromString:@"ba"], @"Simple transposition test failed.");
#endif
}

#ifndef DISABLE_DAMERAU_TRANSPOSITION
- (void)test_restricted {
	XCTAssertEqual((NSUInteger)3, [@"CA" distanceFromString:@"ABC"], @"Restricted test failed.");
}
#endif

- (void)test_case_insensitive {
	levensteinDistance = [@"a" distanceFromString:@"A" 
										  options:JXLDCaseInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Case insensitive test failed.");
}

- (void)test_literal {
	NSString *nWithTilde = @"\U000000F1";
	NSString *nWithTildeDecomposed = @"n\U00000303";
	
	levensteinDistance = [nWithTilde distanceFromString:nWithTildeDecomposed 
												options:0];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Non-literal test failed.");
	
	levensteinDistance = [nWithTilde distanceFromString:nWithTildeDecomposed 
												options:JXLDLiteralComparison];
	XCTAssertEqual((NSUInteger)2, levensteinDistance, @"Literal test failed.");
}

- (void)test_whitespace_insensitive {
	NSString *textWithWhitespace = @"\tDamerau & Levenshtein\n";
	NSString *textWithoutWhitespace = @"Damerau&Levenshtein";
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:0];
	XCTAssertEqual((NSUInteger)4, levensteinDistance, @"Whitespace sensitive test failed.");
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:JXLDWhitespaceInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Whitespace insensitive test failed.");
}

- (void)test_whitespace_trimming {
	NSString *textWithWhitespace = @"\t A \n";
	NSString *textWithoutWhitespace = @"A";
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:0];
	XCTAssertEqual((NSUInteger)4, levensteinDistance, @"Whitespace trimming diabled test failed.");
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:JXLDWhitespaceTrimmingComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Whitespace trimming enabled test failed.");
}

- (void)test_diacritics {
	NSString *textWithDiacritics = @"ÄËÏÖÜ";
	NSString *textWithoutDiacritics = @"AEIOU";
	
	levensteinDistance = [textWithDiacritics distanceFromString:textWithoutDiacritics 
														options:0];
	XCTAssertEqual((NSUInteger)5, levensteinDistance, @"Diacritics sensitive test failed.");
	
	levensteinDistance = [textWithDiacritics distanceFromString:textWithoutDiacritics 
														options:JXLDDiacriticInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Diacritics insensitive test failed.");
}

- (void)test_width {
	NSString *normalA = @"a";
	NSString *wideA = @"\U0000FF41";
	
	levensteinDistance = [normalA distanceFromString:wideA 
														options:0];
	XCTAssertEqual((NSUInteger)1, levensteinDistance, @"Width sensitive test failed.");
	
	levensteinDistance = [normalA distanceFromString:wideA 
														options:JXLDWidthInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Width insensitive test failed.");
}

- (void)test_delimiters {
	NSString *textWithDelimiters = @"string-delimiter_matcher";
	NSString *textWithoutDelimiters = @"string delimiter matcher";
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:0];
	XCTAssertEqual((NSUInteger)2, levensteinDistance, @"Delimiters sensitive test failed.");
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:JXLDDelimiterInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Delimiters insensitive test failed.");
}

- (void)test_delimiters_whitespace_trimming {
	NSString *textWithDelimiters = @"__string-delimiter_matcher--";
	NSString *textWithoutDelimiters = @"string delimiter matcher";
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:0];
	XCTAssertEqual((NSUInteger)6, levensteinDistance, @"Delimiters sensitive test failed.");
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:JXLDDelimiterInsensitiveComparison | JXLDWhitespaceTrimmingComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Delimiters insensitive test failed.");
}

- (void)test_delimiters_whitespace_insensitive {
	NSString *textWithDelimiters = @"__string-delimiter_matcher--";
	NSString *textWithoutDelimiters = @"stringdelimitermatcher";
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:0];
	XCTAssertEqual((NSUInteger)6, levensteinDistance, @"Delimiters sensitive test failed.");
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:JXLDDelimiterInsensitiveComparison | JXLDWhitespaceInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Delimiters insensitive test failed.");
}

- (void)test_quote_types {
	NSString *textWithSmartQuotes = @"“It’s a boy!”";
	NSString *textWithStraightQuotes = @"\"It's a boy!\"";
	
	levensteinDistance = [textWithSmartQuotes distanceFromString:textWithStraightQuotes 
														options:0];
	XCTAssertEqual((NSUInteger)3, levensteinDistance, @"Quote type sensitive test failed.");
	
	levensteinDistance = [textWithSmartQuotes distanceFromString:textWithStraightQuotes 
														options:JXLDQuoteTypeInsensitiveComparison];
	XCTAssertEqual((NSUInteger)0, levensteinDistance, @"Quote type insensitive test failed.");
}

- (void)test_real_world {
	NSString *string1 = @"kitten";
	NSString *string2 = @"sitting";
	
	levensteinDistance = [string1 distanceFromString:string2 
											 options:0];
	XCTAssertEqual((NSUInteger)3, levensteinDistance, @"Real world test #1 failed.");
	
	
	string1 = @"sit-in";
	string2 = @"sitting";
	
	levensteinDistance = [string1 distanceFromString:string2 
											 options:0];
	XCTAssertEqual((NSUInteger)2, levensteinDistance, @"Real world test #4 failed.");
	
}

- (void)test_unicode {
	NSArray *entries = @[@[@"Štein", @"stein", @1U], 
						@[@"Štein", @"Stein", @1U], 
						@[@"Štein", @"steïn", @2U], 
						@[@"Štein", @"Steïn", @2U], 
						@[@"Štein", @"štein", @1U], 
						@[@"Štein", @"šteïn", @2U], 
						@[@"föo", @"foo", @1U], 
						@[@"français", @"francais", @1U], 
						@[@"français", @"franæais", @1U], 
						@[@"私の名前は白です", @"ぼくの名前は白です", @2U]];

	NSString *string1;
	NSString *string2;
	NSUInteger expectedDistance;
	
	for (NSUInteger entryIndex; entryIndex < entries.count; entryIndex++) {
		NSArray *entry = entries[entryIndex];
		string1 = entry[0];
		string2 = entry[1];
		expectedDistance = [entry[2] unsignedIntegerValue];
		
		levensteinDistance = [string1 distanceFromString:string2
												 options:0];
		XCTAssertEqual(expectedDistance, levensteinDistance, @"Unicode test #%lu failed.", (unsigned long)entryIndex+1);
	}
	
}

- (void)test_normalized {
	XCTAssertEqualWithAccuracy(0.0f, [@"123456789" normalizedDistanceFromString:@"123456789"], 0.001f, @"Normalized equality test failed.");

	XCTAssertEqualWithAccuracy(0.5f, [@"12345" normalizedDistanceFromString:@"1234567890"], 0.001f, @"Normalized partial similarity test failed.");
	
	XCTAssertEqualWithAccuracy(1.0f, [@"ABCDE" normalizedDistanceFromString:@"123456789"], 0.001f, @"Normalized no similarity test failed.");

#ifndef DISABLE_DAMERAU_TRANSPOSITION
	XCTAssertEqualWithAccuracy(0.5f, [@"2143658709" normalizedDistanceFromString:@"1234567890"], 0.001f, @"Normalized transposition test failed.");
#endif
}

- (void)test_hasSimilarity {
	XCTAssertTrue([@"123456789" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:1.0f], @"Has Similarity equality test #1 failed.");
	XCTAssertTrue([@"123456789" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.5f], @"Has Similarity equality test #2 failed.");
	XCTAssertTrue([@"123456789" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.0f], @"Has Similarity equality test #3 failed.");

	XCTAssertFalse([@"12345" hasSimilarityToString:@"1234567890" options:0 minimumSimilarity:1.0f], @"Has Similarity partial similarity test #1 failed.");
	XCTAssertTrue([@"12345" hasSimilarityToString:@"1234567890" options:0 minimumSimilarity:0.5f], @"Has Similarity partial similarity test #2 failed.");
	XCTAssertTrue([@"12345" hasSimilarityToString:@"1234567890" options:0 minimumSimilarity:0.0f], @"Has Similarity partial similarity test #3 failed.");
	
	XCTAssertFalse([@"ABCDE" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:1.0f], @"Has Similarity no similarity test #1 failed.");
	XCTAssertFalse([@"ABCDE" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.5f], @"Has Similarity no similarity test #2 failed.");
	XCTAssertTrue([@"ABCDE" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.0f], @"Has Similarity no similarity test #3 failed.");
}

- (void)test_performance {
	levensteinDistance = [DamerauLevenshteinTestsLongString1 distanceFromString:DamerauLevenshteinTestsLongString2];
	XCTAssertEqual((NSUInteger)127*LONG_STRING_EXPANSION_FACTOR, levensteinDistance, @"Perfomance test failed.");
}

- (void)test_semantic_similarity_performance {
	float semanticSimilarity = [DamerauLevenshteinTestsLongString1 semanticSimilarityToString:DamerauLevenshteinTestsLongString2];
	XCTAssertTrue((semanticSimilarity < 1.0f), @"Semantic Similarity Perfomance test failed.");
}

- (void)test_jxst_CFStringPrepareTokenRangesArray {
	{
		CFStringRef testString = (__bridge CFStringRef)DamerauLevenshteinTestsLongString1;
		CFRange testStringRange = CFRangeMake(0, CFStringGetLength(testString));
		CFRange *ranges;
		size_t count = jxst_CFStringPrepareTokenRangesArray(testString, testStringRange, kCFStringTokenizerUnitWord, &ranges, NULL);
		XCTAssertEqual(count, (size_t)(175 * LONG_STRING_EXPANSION_FACTOR), @"jxst_CFStringPrepareTokenRangesArray test #1 failed.");
	}
	
	{
		CFStringRef testString = CFSTR("文\nba abac文\n");
		CFRange testStringRange = CFRangeMake(0, CFStringGetLength(testString));
		CFRange *ranges;
		CFStringTokenizerTokenType *types;
		size_t count = jxst_CFStringPrepareTokenRangesArray(testString, testStringRange, kCFStringTokenizerUnitWordBoundary, &ranges, &types);
		XCTAssertEqual(count, (size_t)7, @"jxst_CFStringPrepareTokenRangesArray test #2 failed.");
		
		CFStringTokenizerTokenType normal = (kCFStringTokenizerTokenNormal);
		CFStringTokenizerTokenType nonLetter = (kCFStringTokenizerTokenNormal | kCFStringTokenizerTokenHasNonLettersMask);
		CFStringTokenizerTokenType normalCJ = (kCFStringTokenizerTokenNormal | kCFStringTokenizerTokenIsCJWordMask);
		CFStringTokenizerTokenType normalGap = (kCFStringTokenizerTokenNormal | jxst_kCFStringTokenizerTokenIsGap);
		
		if (count == 7) {
			XCTAssertEqual(types[0], normalCJ, @"jxst_CFStringPrepareTokenRangesArray test #2.1 failed.");
			XCTAssertEqual(types[1], normalGap,   @"jxst_CFStringPrepareTokenRangesArray test #2.2 failed.");
			XCTAssertEqual(types[2], normal,   @"jxst_CFStringPrepareTokenRangesArray test #2.3 failed.");
			XCTAssertEqual(types[3], nonLetter,   @"jxst_CFStringPrepareTokenRangesArray test #2.4 failed.");
			XCTAssertEqual(types[4], normal,   @"jxst_CFStringPrepareTokenRangesArray test #2.5 failed.");
			XCTAssertEqual(types[5], normalCJ, @"jxst_CFStringPrepareTokenRangesArray test #2.6 failed.");
			XCTAssertEqual(types[6], normalGap,   @"jxst_CFStringPrepareTokenRangesArray test #2.7 failed.");
		}
		
#if 0
		for (size_t i = 0; i < count; i++) {
			CFRange substringRange = ranges[i];
			
			CFStringRef substringString = CFStringCreateWithSubstring(kCFAllocatorDefault, testString, substringRange);
			CFMutableStringRef outString = CFStringCreateMutable(kCFAllocatorDefault, 0);
			CFStringAppendFormat(outString, NULL, CFSTR("'%@'"), substringString);
			CFRelease(substringString);

			CFStringFindAndReplace(outString, CFSTR("\n"), CFSTR("¶"), CFRangeMake(0, CFStringGetLength(outString)), 0);
			
			char *out_chars;
			CFIndex string_length = CFStringGetMaximumSizeForEncoding(CFStringGetLength(outString), kCFStringEncodingUTF8);
			out_chars = malloc(string_length + 1);
			CFStringGetCString(outString, out_chars, string_length + 1, kCFStringEncodingUTF8);
			
			puts(out_chars);
			
			CFRelease(outString);
		}
#endif
	}
}

@end
