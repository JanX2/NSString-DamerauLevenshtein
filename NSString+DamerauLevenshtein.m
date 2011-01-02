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


@implementation NSString (DamerauLevenshtein)

- (NSInteger)distanceFromString:(NSString *)comparisonString;
{
	return [self distanceFromString:comparisonString options:0];
}

- (NSInteger)distanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
{
	NSString *string1;
	NSString *string2;
	
	if (options & JXLDLiteralComparison) {
		string1 = [[self copy] autorelease];
		string2 = [[comparisonString copy] autorelease];
	}
	else {
		string1 = [self decomposedStringWithCanonicalMapping];
		string2 = [comparisonString decomposedStringWithCanonicalMapping];
	}
	
	if (options & JXLDWhitespaceInsensitiveComparison) {
		// Normalize strings
		string1 = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		string2 = [comparisonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}

	if (options & JXLDCaseInsensitiveComparison) {
		string1 = [string1 lowercaseString];
		string2 = [string2 lowercaseString];
	}
	
	// Step 1 (Steps follow description at http://www.merriampark.com/ld.htm )
	NSInteger k, i, j, cost, * d, distance;
	
	NSInteger n = [string1 length];
	NSInteger m = [string2 length];	
	
	if( n++ != 0 && m++ != 0 ) {
		
		d = malloc( sizeof(NSInteger) * m * n );
		
		// Step 2
		for( k = 0; k < n; k++)
			d[k] = k;
		
		for( k = 0; k < m; k++)
			d[ k * n ] = k;
		
		// Step 3 and 4
		for( i = 1; i < n; i++ )
			for( j = 1; j < m; j++ ) {
				
				// Step 5
				if( [string1 characterAtIndex: i-1] == [string2 characterAtIndex: j-1] )
					cost = 0;
				else
					cost = 1;
				
				// Step 6
				d[ j * n + i ] = [string1 smallestOf: d [ (j - 1) * n + i ] + 1
											   andOf: d[ j * n + i - 1 ] +  1
											   andOf: d[ (j - 1) * n + i - 1 ] + cost ];
				
				// This conditional adds Damerau transposition to Levenshtein distance
				if( i>1 
				   && j>1 
				   && [string1 characterAtIndex: i-1] == [string2 characterAtIndex: j-2] 
				   && [string1 characterAtIndex: i-2] == [string2 characterAtIndex: j-1] )
				{
					d[ j * n + i] = [string1 smallestOf: d[ j * n + i ]
												  andOf: d[ (j - 2) * n + i - 2 ] + cost ];
				}
			}
		
		distance = d[ n * m - 1 ];
		
		free( d );
		
		return distance;
		
	}
	
	return 0;
	
}

// Return the minimum of a, b and c - used by compareString:withString:
- (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b andOf:(NSInteger)c;
{
	NSInteger min = a;
	if ( b < min )
		min = b;
	
	if( c < min )
		min = c;
	
	return min;
}

- (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b;
{
	NSInteger min=a;
	if (b < min)
		min=b;
	
	return min;
}


@end
