//
//  NSString+JXCodePointEnumeration.h
//  JXNumberStringProcessing
//
//  Created by Jan on 07.06.14.
//  Copyright (c) 2014-2015 Jan Weiß. All rights reserved.
//
//  MIT License.
//  License information is at the end of this file.

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, JXCodePointEnumerationOptions) {
    JXCodePointEnumerationOptionsRangeNotRequired = 1UL << 0,
	JXCodePointEnumerationReverse = 1UL << 1,
};

@interface NSString (JXCodePointEnumeration)

// Enumerates Unicode code points, not composed character sequences!
// The range must neither start nor end withing a surrogate pair.
// The string must be valid Unicode.
// Use -rangeOfComposedCharacterSequencesForRange: if unsure, if the above applies.
- (void)enumerateCodePointsWithOptionsJX:(JXCodePointEnumerationOptions)opts
							  usingBlock:(void (^)(UTF32Char codePoint, NSRange range, BOOL *stop))block;

- (void)enumerateCodePointsInRange:(NSRange)range
						 optionsJX:(JXCodePointEnumerationOptions)opts
						usingBlock:(void (^)(UTF32Char codePoint, NSRange range, BOOL *stop))block;

- (NSUInteger)countOccurancesOfCharactersInSetJX:(NSCharacterSet *)characterSet;

- (NSUInteger)countOccurancesOfDecimalDigitsJX;

@end

/*
 * Author: jan@geheimwerk.de (Jan Weiß)
 *
 * Copyright (c) 2015 Jan Weiß
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

