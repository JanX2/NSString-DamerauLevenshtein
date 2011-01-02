//
//  NSString+DamerauLevenshtein.h
//  DamerauLevenshtein
//
//  Created by Jan on 02.01.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//
//  MIT License. 
//  License information is at the end of this file. 

#import <Foundation/Foundation.h>

enum {
    JXLDCaseInsensitiveComparison = 1,
	JXLDLiteralComparison = 2,					/* Exact character-by-character equivalence */
	JXLDWhitespaceInsensitiveComparison = 4,
    JXLDDiacriticInsensitiveComparison = 128,	/* If specified, ignores diacritics (o-umlaut == o) */
    JXLDWidthInsensitiveComparison = 256,		/* If specified, ignores width differences ('a' == UFF41) */
};
typedef NSUInteger JXLDStringDistanceOptions;

@interface NSString (DamerauLevenshtein)

- (NSInteger)distanceFromString:(NSString *)comparisonString;
- (NSInteger)distanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;
- (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b andOf:(NSInteger)c;
- (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b;

@end

/*
 * Author: support@wanderingmango.com (K. Darcy Otto)
 * Author: jan@geheimwerk.de (Jan Weiß)
 *
 * Copyright (c) 2010 geheimwerk.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

