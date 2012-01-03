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
	JXLDWhitespaceTrimmingComparison = 8,		/* If specified, trims white space from both ends (" A " == "A") */
    JXLDDiacriticInsensitiveComparison = 128,	/* If specified, ignores diacritics (o-umlaut == o) */
    JXLDWidthInsensitiveComparison = 256,		/* If specified, ignores width differences ('a' == UFF41) */
};
typedef NSUInteger JXLDStringDistanceOptions;

