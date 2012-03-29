//
//  SHKBuffer.m
//  BufferShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 Buffer, Inc. All rights reserved.
//

#import "SHKBuffer.h"
#import "SHKBufferOAuthView.h"
#import "SHKBufferSheetView.h"

@implementation SHKBuffer

@synthesize accessToken;

static NSString *authorizeURL = @"https://bufferapp.com/oauth2/authorize";
static NSString *bufferCallbackUrl = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *accessTokenKey = @"SHKBufferAccessToken";

- (id)init {
    if (self = [super init]){
        self.accessToken = nil;
	}	
	return self;
}


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle {
	return @"Buffer";
}

+ (BOOL)canShareURL {
    return YES;
}

+ (BOOL)canShareImage {
    return YES;
}

+ (BOOL)canShareText {
    return YES;
}

+ (BOOL)canShareOffline {
	return NO;
}

#pragma mark -
#pragma mark Configuration : Dynamic Enable

// Subclass if you need to dynamically enable/disable the action.  (For example if it only works with specific hardware)
+ (BOOL)canShare {
	return YES;
}


#pragma mark -
#pragma mark Authorize

- (BOOL)isAuthorized {		
	return [self restoreAccessToken];
}


- (void)promptAuthorization {
    SHKBufferOAuthView *auth = [[SHKBufferOAuthView alloc] init];
    auth.delegate = self;
	[[SHK currentHelper] showViewController:auth];
	[auth release];
}

- (NSURL *)authorizeCallbackURL {
	return [NSURL URLWithString: bufferCallbackUrl];
}

- (void)storeAccessToken:(NSString *)token {
    NSLog(@"Store!");
	[SHK setAuthValue:token
               forKey:@"SHKBufferAccessToken"
            forSharer:[self sharerId]];
    
    [[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
}
 
- (BOOL)restoreAccessToken {
	if (self.accessToken != nil)
		return YES;
    
	self.accessToken = [SHK getAuthValueForKey:accessTokenKey
                                     forSharer:[self sharerId]];
	
	return self.accessToken != nil;
}



- (void)show {
    if (item.shareType == SHKShareTypeURL) {
		//[self shortenURL];
	} else if (item.shareType == SHKShareTypeImage) {
		[item setCustomValue:item.title forKey:@"status"];
	} else if (item.shareType == SHKShareTypeText) {
		[item setCustomValue:item.text forKey:@"status"];
	}
    
    
    SHKBufferSheetView *bufferSheet = [[SHKBufferSheetView alloc] initWithToken:self.accessToken];
    bufferSheet.delegate = self;
	[self pushViewController:bufferSheet animated:NO];
	[[SHK currentHelper] showViewController:self];
}



#pragma mark -
#pragma mark Requests


-(void)postBufferUpdate:(NSString *)updateText toProfiles:(NSMutableArray *)profiles {
    [[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Posting...")];
    
    NSString *postUrl = [NSString stringWithFormat:@"https://api.bufferapp.com/1/updates/create.json?access_token=%@", self.accessToken];
    
    NSString *postParams = [NSString stringWithFormat:@"text=%@&shorten=0&profile_ids[]=%@", updateText, [profiles componentsJoinedByString:@"&profile_ids[]="]];
    
    
    self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:postUrl]
                                             params:postParams
                                           delegate:self
                                 isFinishedSelector:@selector(updatePosted:)
                                             method:@"POST"
                                          autostart:YES] autorelease];
    
}

-(void)updatePosted:(SHKRequest *)aRequest {
    [[SHKActivityIndicator currentIndicator] hide];
    
    if (aRequest.success) {
        // Notify delegate
        [self sendDidFinish];
    } else {
        [self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem adding to Buffer.")]];
    }
}

@end
