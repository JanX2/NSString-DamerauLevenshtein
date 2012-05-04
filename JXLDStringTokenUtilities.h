//
//  JXLDStringTokenUtilities.h
//  Damerau-Levenshtein
//
//  Created by Jan on 04.05.12.
//  Copyright (c) 2012 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

int jxst_CFStringPrepareTokenRangesArray(CFStringRef string, CFRange tokenizerRange, CFOptionFlags tokenizerOptions, CFRange **ranges);
