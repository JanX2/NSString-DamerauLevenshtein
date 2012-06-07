//
//  NSString+DamerauLevenshtein.h
//  DamerauLevenshtein
//
//  Created by Jan on 02.01.11.
//  Copyright 2011-2012 geheimwerk.de. All rights reserved.
//
//  MIT License. 
//  License information is at the end of this file. 

#import <Foundation/Foundation.h>

#import "JXLDStringDistance.h"
#import "JXLDWeights.h"


@interface NSString (DamerauLevenshtein)

/*
 Calculates the Damerau-Levenshtein distance between self and a second string. 
 The returned value is a count of the differences between the two strings.  
 This can then be used for fuzzy string matching.  
 See http://en.wikipedia.org/wiki/Levenstein_Distance for more information about the basic algorithm. 
 */
- (NSUInteger)distanceFromString:(NSString *)comparisonString;

// See JXLDStringDistanceOptions in JXLDStringDistance.h for a description of the options. 
- (NSUInteger)distanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;

- (float)semanticDistanceFromString:(NSString *)comparisonString;
- (float)semanticDistanceFromString:(NSString *)comparisonString weights:(JXLDWeights)weight;
- (float)semanticSimilarityToString:(NSString *)comparisonString;
- (float)semanticSimilarityToString:(NSString *)comparisonString weights:(JXLDWeights)weight;

// The return value of -distanceFromString:options: is normalized to the interval [0.0f, 1.0f] (0% to 100% distance)
- (float)normalizedDistanceFromString:(NSString *)comparisonString;
- (float)normalizedDistanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;

// These methods just invert the value of -normalizedDistanceFromString:options: (100% to 0% similarity)
- (float)similarityToString:(NSString *)comparisonString;
- (float)similarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options;

// These methods perform some speed optimizations only possible with the given bounds
- (float)normalizedDistanceFromString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options maximumDistance:(float)maxDistance;
- (float)similarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options minimumSimilarity:(float)minSimilarity;
- (BOOL)hasSimilarityToString:(NSString *)comparisonString options:(JXLDStringDistanceOptions)options minimumSimilarity:(float)minSimilarity;

- (NSComparisonResult)jxld_compare:(NSString *)aString options:(JXLDStringDistanceOptions)options;
- (NSString *)jxld_transformWithOptions:(JXLDStringDistanceOptions)options;

/*
 Currently this implements the restricted form of Damerau-Levenshtein. 
 Please contact me (Jan Weiß) should you have implemented the unrestricted form.
 See http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Applications for details.
 */
@end

/*
 * Author: support@wanderingmango.com (K. Darcy Otto)
 * Author: jan@geheimwerk.de (Jan Weiß)
 *
 * Copyright (c) 2011-2012 geheimwerk.de
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

