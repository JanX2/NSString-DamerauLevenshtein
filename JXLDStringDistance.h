//
//  JXLDStringDistance.h
//  DamerauLevenshtein
//
//  Created by Jan on 18.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//
//  MIT License.

enum {
    JXLDCaseInsensitiveComparison = 1,			/* If specified, ignores the case (a == A) */
	JXLDLiteralComparison = 2,					/* Exact character-by-character equivalence */
	JXLDWhitespaceInsensitiveComparison = 4,	/* If specified, ignores white space */
	JXLDWhitespaceTrimmingComparison = 8,		/* If specified, trims white space from both ends (" A B C " == "A B C") */
    JXLDDiacriticInsensitiveComparison = 128,	/* If specified, ignores diacritics (o-umlaut == o) */
    JXLDWidthInsensitiveComparison = 256,		/* If specified, ignores width differences ('a' == U+FF41) */
    JXLDDelimiterInsensitiveComparison = 512,	/* If specified, replaces common delimiters ('_', '-') with space (' ') before comparison */
    JXLDQuoteTypeInsensitiveComparison = 1024,	/* If specified, replaces curly quotes (“”‘’) with straigh ones ("') before comparison */
};
typedef NSUInteger JXLDStringDistanceOptions;

/*
Important:
 
Please note that JXLDDelimiterInsensitiveComparison is processed before JXLDWhitespaceInsensitiveComparison and JXLDWhitespaceTrimmingComparison.
This results is that the affected delimiter characters are effectively being removed before the comparison takes place
(all for the former option, only those at both ends for the latter).
*/
