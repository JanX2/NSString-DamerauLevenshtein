//
//  JXLDStringTokenUtilities.h
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012-2015 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

CF_EXPORT CFOptionFlags jxst_kCFStringTokenizerTokenIsGap;

size_t jxst_CFStringPrepareTokenRangesArray(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges, CFStringTokenizerTokenType **types);
