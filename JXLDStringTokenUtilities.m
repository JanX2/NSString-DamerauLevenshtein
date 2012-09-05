//
//  JXLDStringTokenUtilities.m
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012 geheimwerk.de. All rights reserved.
//

#import "JXLDStringTokenUtilities.h"

typedef struct {
	CFRange *array;
	CFStringTokenizerTokenType *types;
	size_t used;
	size_t capacity;
} TokenRangesArray;

CF_INLINE void assureTokenRangesArrayCapacity(TokenRangesArray *tokenRanges_p) {
    if (tokenRanges_p->capacity == tokenRanges_p->used) {
        tokenRanges_p->capacity *= 2;
        tokenRanges_p->array = realloc(tokenRanges_p->array, (tokenRanges_p->capacity * sizeof(CFRange)));
		if (tokenRanges_p->types != NULL) {
			tokenRanges_p->types = realloc(tokenRanges_p->types, (tokenRanges_p->capacity * sizeof(CFStringTokenizerTokenType)));
		}
    }
}

size_t jxst_CFStringPrepareTokenRangesArray(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges, CFStringTokenizerTokenType **types) {
	// This function contains a very crude pseudo-dynamic array implementation as it is a pain to work with CFRange structs and CFArray objects.
	// Don’t forget to free the ranges array when you are done with it!
	TokenRangesArray tokenRanges = {
		.used = 0,
		.capacity = 4,
		.array = malloc(tokenRanges.capacity * sizeof(CFRange)),
		.types = (types != NULL) ? malloc(tokenRanges.capacity * sizeof(CFStringTokenizerTokenType)) : NULL
	};
	
	CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, tokenizerRange, tokenizerOptions, NULL);

	Boolean detectGaps = (tokenizerOptions != kCFStringTokenizerUnitWord);

	// Set tokenizer to the start of the string. 
	CFStringTokenizerTokenType tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
	
	CFRange tokenRange;
	CFIndex prevTokenRangeMax = 0;
	while (tokenType != kCFStringTokenizerTokenNone) {
		assureTokenRangesArrayCapacity(&tokenRanges);
		
		tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
		
		if (detectGaps && tokenRange.location > prevTokenRangeMax) {
			// Gaps are expected behaviour when using kCFStringTokenizerUnitWord, 
			// but for some reason, gaps in other tokenizations can appear.
			// One particular example is the tokenizer skipping a line feed ('\n') directly after a string of Chinese characters when using kCFStringTokenizerUnitWordBoundary. 
			assureTokenRangesArrayCapacity(&tokenRanges);
			CFRange gapRange = CFRangeMake(prevTokenRangeMax, (tokenRange.location - prevTokenRangeMax));
			if (tokenRanges.types != NULL)  tokenRanges.types[tokenRanges.used] = kCFStringTokenizerTokenNormal;
			tokenRanges.array[tokenRanges.used++] = gapRange;
		}
		
		if (tokenRanges.types != NULL)  tokenRanges.types[tokenRanges.used] = tokenType;
		tokenRanges.array[tokenRanges.used++] = tokenRange;

		prevTokenRangeMax = (tokenRange.location + tokenRange.length);
		
		tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
	}
	
	CFRelease(tokenizer);
	
	*ranges = tokenRanges.array;
	if (types != NULL) {
		*types = tokenRanges.types;
	}
	
	return tokenRanges.used;
}

