//
//  SHKBuffer.m
//  BufferShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=4f6db4dc512f7ec56f00000a&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob", authorizeURL]];
    
    SHKBufferOAuthView *auth = [[SHKBufferOAuthView alloc] initWithSender:self];
	[[SHK currentHelper] showViewController:auth];
	[auth release];
	
}

- (NSURL *)authorizeCallbackURL {
	return [NSURL URLWithString: bufferCallbackUrl];
}


/*
- (void)tokenAuthorizeView:(SHKOAuthView *)authView didFinishWithSuccess:(BOOL)success queryParams:(NSMutableDictionary *)queryParams error:(NSError *)error {
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
    if (success) {
        NSLog(@"token %@", [queryParams objectForKey:@"access_token"]);
        self.accessToken = [queryParams objectForKey:@"access_token"];
        [self storeAccessToken];
        [self tryPendingAction];
    } else {
        [[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Access Error")
                                     message:error!=nil?[error localizedDescription]:SHKLocalizedString(@"There was an error while sharing")
                                    delegate:nil
                           cancelButtonTitle:SHKLocalizedString(@"Close")
                           otherButtonTitles:nil] autorelease] show];
    }
    
    NSLog(@"Did Finish");
    
    //[self authDidFinish:success];
}

- (void)tokenAuthorizeCancelledView:(SHKOAuthView *)authView {
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
    //[self authDidFinish:NO];
}
*/

- (void)storeAccessToken:(NSString *)token {
    
    NSLog(@"Store!!!");
    
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

/*
+ (void)deleteStoredAccessToken {
	NSString *sharerId = [self sharerId];
	
	[SHK removeAuthValueForKey:accessTokenKey forSharer:sharerId];
}

+ (void)logout {
	[self deleteStoredAccessToken];
	
	// Clear cookies 
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:authorizeURL]];
    for (NSHTTPCookie *each in cookies)  {
        [storage deleteCookie:each];
    }
}
*/




- (void)show {
    SHKBufferSheetView *bufferSheet = [[SHKBufferSheetView alloc] initWithToken:self.accessToken];
	
	[self pushViewController:bufferSheet animated:NO];
	
	[[SHK currentHelper] showViewController:self];
}




@end
