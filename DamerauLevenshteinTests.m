//
//  DamerauLevenshteinTests.m
//  Damerau-Levenshtein
//
//  Created by Jan on 02.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//

#import "DamerauLevenshteinTests.h"

#import "NSString+DamerauLevenshtein.h"

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
	STAssertEquals((NSUInteger)0, [@"" distanceFromString:@""], @"Empty test #1 failed.");

	STAssertEquals((NSUInteger)1, [@"" distanceFromString:@"a"], @"Empty test #2 failed.");

	STAssertEquals((NSUInteger)1, [@"a" distanceFromString:@""], @"Empty test #3 failed.");
}

- (void)test_simple {
	STAssertEquals((NSUInteger)1, [@"ab" distanceFromString:@"abc"], @"Simple insertion test failed.");

	STAssertEquals((NSUInteger)1, [@"ab" distanceFromString:@"a"], @"Simple deletion test failed.");

	STAssertEquals((NSUInteger)1, [@"ab" distanceFromString:@"az"], @"Simple substitution test failed.");

#ifndef DISABLE_DAMERAU_TRANSPOSITION
	STAssertEquals((NSUInteger)1, [@"ab" distanceFromString:@"ba"], @"Simple transposition test failed.");
#endif
}

#ifndef DISABLE_DAMERAU_TRANSPOSITION
- (void)test_restricted {
	STAssertEquals((NSUInteger)3, [@"CA" distanceFromString:@"ABC"], @"Restricted test failed.");
}
#endif

- (void)test_case_insensitive {
	levensteinDistance = [@"a" distanceFromString:@"A" 
										  options:JXLDCaseInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Case insensitive test failed.");
}

- (void)test_literal {
	NSString *nWithTilde = @"\U000000F1";
	NSString *nWithTildeDecomposed = @"n\U00000303";
	
	levensteinDistance = [nWithTilde distanceFromString:nWithTildeDecomposed 
												options:0];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Non-literal test failed.");
	
	levensteinDistance = [nWithTilde distanceFromString:nWithTildeDecomposed 
												options:JXLDLiteralComparison];
	STAssertEquals((NSUInteger)2, levensteinDistance, @"Literal test failed.");
}

- (void)test_whitespace_insensitive {
	NSString *textWithWhitespace = @"\tDamerau & Levenshtein\n";
	NSString *textWithoutWhitespace = @"Damerau&Levenshtein";
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:0];
	STAssertEquals((NSUInteger)4, levensteinDistance, @"Whitespace sensitive test failed.");
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:JXLDWhitespaceInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Whitespace insensitive test failed.");
}

- (void)test_whitespace_trimming {
	NSString *textWithWhitespace = @"\t A \n";
	NSString *textWithoutWhitespace = @"A";
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:0];
	STAssertEquals((NSUInteger)4, levensteinDistance, @"Whitespace trimming diabled test failed.");
	
	levensteinDistance = [textWithWhitespace distanceFromString:textWithoutWhitespace 
												options:JXLDWhitespaceTrimmingComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Whitespace trimming enabled test failed.");
}

- (void)test_diacritics {
	NSString *textWithDiacritics = @"ÄËÏÖÜ";
	NSString *textWithoutDiacritics = @"AEIOU";
	
	levensteinDistance = [textWithDiacritics distanceFromString:textWithoutDiacritics 
														options:0];
	STAssertEquals((NSUInteger)5, levensteinDistance, @"Diacritics sensitive test failed.");
	
	levensteinDistance = [textWithDiacritics distanceFromString:textWithoutDiacritics 
														options:JXLDDiacriticInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Diacritics insensitive test failed.");
}

- (void)test_width {
	NSString *normalA = @"a";
	NSString *wideA = @"\U0000FF41";
	
	levensteinDistance = [normalA distanceFromString:wideA 
														options:0];
	STAssertEquals((NSUInteger)1, levensteinDistance, @"Width sensitive test failed.");
	
	levensteinDistance = [normalA distanceFromString:wideA 
														options:JXLDWidthInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Width insensitive test failed.");
}

- (void)test_delimiters {
	NSString *textWithDelimiters = @"string-delimiter_matcher";
	NSString *textWithoutDelimiters = @"string delimiter matcher";
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:0];
	STAssertEquals((NSUInteger)2, levensteinDistance, @"Delimiters sensitive test failed.");
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:JXLDDelimiterInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Delimiters insensitive test failed.");
}

- (void)test_delimiters_whitespace_trimming {
	NSString *textWithDelimiters = @"__string-delimiter_matcher--";
	NSString *textWithoutDelimiters = @"string delimiter matcher";
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:0];
	STAssertEquals((NSUInteger)6, levensteinDistance, @"Delimiters sensitive test failed.");
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:JXLDDelimiterInsensitiveComparison | JXLDWhitespaceTrimmingComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Delimiters insensitive test failed.");
}

- (void)test_delimiters_whitespace_insensitive {
	NSString *textWithDelimiters = @"__string-delimiter_matcher--";
	NSString *textWithoutDelimiters = @"stringdelimitermatcher";
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:0];
	STAssertEquals((NSUInteger)6, levensteinDistance, @"Delimiters sensitive test failed.");
	
	levensteinDistance = [textWithDelimiters distanceFromString:textWithoutDelimiters 
														options:JXLDDelimiterInsensitiveComparison | JXLDWhitespaceInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Delimiters insensitive test failed.");
}

- (void)test_quote_types {
	NSString *textWithSmartQuotes = @"“It’s a boy!”";
	NSString *textWithStraightQuotes = @"\"It's a boy!\"";
	
	levensteinDistance = [textWithSmartQuotes distanceFromString:textWithStraightQuotes 
														options:0];
	STAssertEquals((NSUInteger)3, levensteinDistance, @"Quote type sensitive test failed.");
	
	levensteinDistance = [textWithSmartQuotes distanceFromString:textWithStraightQuotes 
														options:JXLDQuoteTypeInsensitiveComparison];
	STAssertEquals((NSUInteger)0, levensteinDistance, @"Quote type insensitive test failed.");
}

- (void)test_real_world {
	NSString *string1 = @"kitten";
	NSString *string2 = @"sitting";
	
	levensteinDistance = [string1 distanceFromString:string2 
											 options:0];
	STAssertEquals((NSUInteger)3, levensteinDistance, @"Real world test #1 failed.");
	
	
	string1 = @"sit-in";
	string2 = @"sitting";
	
	levensteinDistance = [string1 distanceFromString:string2 
											 options:0];
	STAssertEquals((NSUInteger)2, levensteinDistance, @"Real world test #4 failed.");
	
}

- (void)test_unicode {
	NSArray *entries = [NSArray arrayWithObjects:
						[NSArray arrayWithObjects:@"Štein", @"stein", [NSNumber numberWithUnsignedInteger:1], nil], 
						[NSArray arrayWithObjects:@"Štein", @"Stein", [NSNumber numberWithUnsignedInteger:1], nil], 
						[NSArray arrayWithObjects:@"Štein", @"steïn", [NSNumber numberWithUnsignedInteger:2], nil], 
						[NSArray arrayWithObjects:@"Štein", @"Steïn", [NSNumber numberWithUnsignedInteger:2], nil], 
						[NSArray arrayWithObjects:@"Štein", @"štein", [NSNumber numberWithUnsignedInteger:1], nil], 
						[NSArray arrayWithObjects:@"Štein", @"šteïn", [NSNumber numberWithUnsignedInteger:2], nil], 
						[NSArray arrayWithObjects:@"föo", @"foo", [NSNumber numberWithUnsignedInteger:1], nil], 
						[NSArray arrayWithObjects:@"français", @"francais", [NSNumber numberWithUnsignedInteger:1], nil], 
						[NSArray arrayWithObjects:@"français", @"franæais", [NSNumber numberWithUnsignedInteger:1], nil], 
						[NSArray arrayWithObjects:@"私の名前は白です", @"ぼくの名前は白です", [NSNumber numberWithUnsignedInteger:2], nil], nil];

	NSString *testFailedMessage;

	NSString *string1;
	NSString *string2;
	NSUInteger expectedDistance;
	
	for (NSUInteger entryIndex; entryIndex < entries.count; entryIndex++) {
		NSArray *entry = [entries objectAtIndex:entryIndex];
		string1 = [entry objectAtIndex:0];
		string2 = [entry objectAtIndex:1];
		expectedDistance = [[entry objectAtIndex:2] unsignedIntegerValue];
		
		testFailedMessage = [NSString stringWithFormat:@"Unicode test #%lu failed.", (unsigned long)entryIndex+1];
		
		levensteinDistance = [string1 distanceFromString:string2 
												 options:0];
		STAssertEquals(expectedDistance, levensteinDistance, testFailedMessage);
	}
	
}

- (void)test_normalized {
	STAssertEqualsWithAccuracy(0.0f, [@"123456789" normalizedDistanceFromString:@"123456789"], 0.001f, @"Normalized equality test failed.");

	STAssertEqualsWithAccuracy(0.5f, [@"12345" normalizedDistanceFromString:@"1234567890"], 0.001f, @"Normalized partial similarity test failed.");
	
	STAssertEqualsWithAccuracy(1.0f, [@"ABCDE" normalizedDistanceFromString:@"123456789"], 0.001f, @"Normalized no similarity test failed.");

#ifndef DISABLE_DAMERAU_TRANSPOSITION
	STAssertEqualsWithAccuracy(0.5f, [@"2143658709" normalizedDistanceFromString:@"1234567890"], 0.001f, @"Normalized transposition test failed.");
#endif
}

- (void)test_hasSimilarity {
	STAssertTrue([@"123456789" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:1.0f], @"Has Similarity equality test #1 failed.");
	STAssertTrue([@"123456789" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.5f], @"Has Similarity equality test #2 failed.");
	STAssertTrue([@"123456789" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.0f], @"Has Similarity equality test #3 failed.");

	STAssertFalse([@"12345" hasSimilarityToString:@"1234567890" options:0 minimumSimilarity:1.0f], @"Has Similarity partial similarity test #1 failed.");
	STAssertTrue([@"12345" hasSimilarityToString:@"1234567890" options:0 minimumSimilarity:0.5f], @"Has Similarity partial similarity test #2 failed.");
	STAssertTrue([@"12345" hasSimilarityToString:@"1234567890" options:0 minimumSimilarity:0.0f], @"Has Similarity partial similarity test #3 failed.");
	
	STAssertFalse([@"ABCDE" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:1.0f], @"Has Similarity no similarity test #1 failed.");
	STAssertFalse([@"ABCDE" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.5f], @"Has Similarity no similarity test #2 failed.");
	STAssertTrue([@"ABCDE" hasSimilarityToString:@"123456789" options:0 minimumSimilarity:0.0f], @"Has Similarity no similarity test #3 failed.");
}

- (void)test_performance {
	levensteinDistance = [DamerauLevenshteinTestsLongString1 distanceFromString:DamerauLevenshteinTestsLongString2];
	STAssertEquals((NSUInteger)127*LONG_STRING_EXPANSION_FACTOR, levensteinDistance, @"Perfomance test failed.");
}

- (void)test_semantic_similarity_performance {
	float semanticSimilarity = [DamerauLevenshteinTestsLongString1 semanticSimilarityToString:DamerauLevenshteinTestsLongString2];
	STAssertTrue((semanticSimilarity < 1.0f), @"Semantic Similarity Perfomance test failed.");
}

@end
