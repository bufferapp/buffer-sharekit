//
//  NSString+Encode.h
//  Buffer
//
//  Created by Andrew Yates on 26/11/2011.
//  Copyright (c) 2011 Buffer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (encode)
- (NSString *)encodeString:(NSStringEncoding)encoding;
@end