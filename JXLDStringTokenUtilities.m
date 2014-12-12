//
//  JXLDStringTokenUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012 geheimwerk.de. All rights reserved.
//

#import "JXLDStringTokenUtilities.h"

CFOptionFlags jxst_kCFStringTokenizerTokenIsGap                              = 1UL << ((sizeof(unsigned long) * CHAR_BIT) -1);

typedef struct {
	CFRange *array;
	CFStringTokenizerTokenType *types;
	size_t used;
	size_t capacity;
} TokenRangesArray;

CF_INLINE void assureTokenRangesArrayCapacity(TokenRangesArray *tokenRanges_p) {
    if (tokenRanges_p->capacity == tokenRanges_p->used) {
        tokenRanges_p->capacity *= 2;
        tokenRanges_p->array = reallocf(tokenRanges_p->array, (tokenRanges_p->capacity * sizeof(CFRange)));
		
		if (tokenRanges_p->types != NULL) {
			tokenRanges_p->types = reallocf(tokenRanges_p->types, (tokenRanges_p->capacity * sizeof(CFStringTokenizerTokenType)));
		}
    }
}

CF_INLINE void addToTokenRangesArray(TokenRangesArray *tokenRanges_p, CFRange tokenRange, CFStringTokenizerTokenType tokenType) {
	assureTokenRangesArrayCapacity(tokenRanges_p);
	if (tokenRanges_p->types != NULL)  tokenRanges_p->types[tokenRanges_p->used] = tokenType;
	tokenRanges_p->array[tokenRanges_p->used] = tokenRange;
	tokenRanges_p->used++;
}

size_t jxst_CFStringPrepareTokenRangesArray(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges, CFStringTokenizerTokenType **types) {
	// This function contains a very crude pseudo-dynamic array implementation as it is a pain to work with CFRange structs and CFArray objects.
	// Don’t forget to free the ranges array when you are done with it!
	TokenRangesArray tokenRanges = {
		.used = 0,
		.capacity = 4,
	};
	tokenRanges.array = malloc(tokenRanges.capacity * sizeof(CFRange));
	tokenRanges.types = (types != NULL) ? malloc(tokenRanges.capacity * sizeof(CFStringTokenizerTokenType)) : NULL;
	
	CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, tokenizerRange, tokenizerOptions, NULL);

	Boolean detectGaps = (tokenizerOptions != kCFStringTokenizerUnitWord);

	// Set tokenizer to the start of the string. 
	CFStringTokenizerTokenType tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
	CFStringTokenizerTokenType gapTokenType = (kCFStringTokenizerTokenNormal | jxst_kCFStringTokenizerTokenIsGap);
	
	CFRange tokenRange;
	CFIndex prevTokenRangeMax = 0;
	while (tokenType != kCFStringTokenizerTokenNone) {
		tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
		
		if (detectGaps && (tokenRange.location > prevTokenRangeMax)) {
			// Gaps are expected behaviour when using kCFStringTokenizerUnitWord, 
			// but for some reason, gaps in other tokenizations can appear.
			// One particular example is the tokenizer skipping a line feed ('\n') directly after a string of Chinese characters when using kCFStringTokenizerUnitWordBoundary. 
			CFRange gapRange = CFRangeMake(prevTokenRangeMax, (tokenRange.location - prevTokenRangeMax));
			addToTokenRangesArray(&tokenRanges, gapRange, gapTokenType);
		}
		
		addToTokenRangesArray(&tokenRanges, tokenRange, tokenType);

		prevTokenRangeMax = (tokenRange.location + tokenRange.length);
		
		tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
	}
	
	if (detectGaps) {
		CFIndex stringLength = CFStringGetLength(string);
		if (stringLength > prevTokenRangeMax) {
			CFRange gapRange = CFRangeMake(prevTokenRangeMax, (stringLength - prevTokenRangeMax));
			addToTokenRangesArray(&tokenRanges, gapRange, gapTokenType);
		}
	}
	
	CFRelease(tokenizer);
	
	*ranges = tokenRanges.array;
	if (types != NULL) {
		*types = tokenRanges.types;
	}
	
	return tokenRanges.used;
}

