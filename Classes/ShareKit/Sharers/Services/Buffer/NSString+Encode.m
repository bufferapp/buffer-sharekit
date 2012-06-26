//
//  NSString+Encode.m
//  Buffer
//
//  Created by Andrew Yates on 26/11/2011.
//  Copyright (c) 2011 Buffer, Inc. All rights reserved.
//

#import "NSString+Encode.h"

@implementation NSString (encode)
- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding));
}  
@end