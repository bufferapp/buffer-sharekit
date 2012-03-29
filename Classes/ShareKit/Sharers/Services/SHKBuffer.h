//
//  SHKBuffer.h
//  BufferShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 Buffer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHKSharer.h"

@interface SHKBuffer : SHKSharer {
    NSString *accessToken;
}

@property (nonatomic, copy) NSString *accessToken;

- (void)storeAccessToken;
- (BOOL)restoreAccessToken;
+ (void)deleteStoredAccessToken;

-(void)postBufferUpdate:(NSString *)updateText toProfiles:(NSMutableArray *)profiles;

@end
