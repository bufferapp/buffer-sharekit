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
    return NO;
}

+ (BOOL)canShareText {
    return NO;
}

+ (BOOL)canShareOffline {
	return YES;
}

#pragma mark -
#pragma mark Configuration : Dynamic Enable

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
	self.accessToken = token;
	[SHK setAuthValue:token
               forKey:@"SHKBufferAccessToken"
            forSharer:[self sharerId]];
    
	[self tryToSend];
}
 
- (BOOL)restoreAccessToken {
	if (self.accessToken != nil)
		return YES;
    
	self.accessToken = [SHK getAuthValueForKey:accessTokenKey
                                     forSharer:[self sharerId]];
	
	return self.accessToken != nil;
}

+(void)logout {
	[super logout];
	[SHK setAuthValue:nil forKey:@"SHKBufferAccessToken" forSharer:self];
}

- (void)show {
    NSString *updateText = @"";
    
    if (item.shareType == SHKShareTypeURL) {
        updateText = [NSString stringWithFormat:@"%@ - %@", item.title, item.URL];
	}
    
    SHKBufferSheetView *bufferSheet = [[SHKBufferSheetView alloc] initWithToken:self.accessToken];
    bufferSheet.delegate = self;
    bufferSheet.updateCopy = updateText;
    
	[self pushViewController:bufferSheet animated:NO];
	[[SHK currentHelper] showViewController:self];
}

-(BOOL)send {
	//[self show];
    return NO;
} 

-(void)sendDidFinish {
	[super sendDidFinish];
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Requests


-(void)postBufferUpdate:(NSString *)updateText toProfiles:(NSMutableArray *)profiles {
    if (![[self class] shareRequiresInternetConnection] || [SHK connected]){
        [[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Posting...")];
        
        NSString *postUrl = [NSString stringWithFormat:@"https://api.bufferapp.com/1/updates/create.json?access_token=%@", self.accessToken];
        
        NSString *postParams = [NSString stringWithFormat:@"text=%@&shorten=0&profile_ids[]=%@", updateText, [profiles componentsJoinedByString:@"&profile_ids[]="]];
        
        
        self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:postUrl]
                                                 params:postParams
                                               delegate:self
                                     isFinishedSelector:@selector(updatePosted:)
                                                 method:@"POST"
                                              autostart:YES] autorelease];
    } else if ([[self class] canShareOffline]) {
        [SHK addToOfflineQueue:item forSharer:[self sharerId]];
        NSLog(@"Adding to Offline Queue.");
        NSLog(@"queue %@", [SHK getOfflineQueueList]);
    }
}

-(void)updatePosted:(SHKRequest *)aRequest {
    [[SHKActivityIndicator currentIndicator] hide];
    
    if (aRequest.success) {
        [self sendDidFinish];
    } else {
        [self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem adding to Buffer.")]];
    }
}


#pragma mark -
#pragma mark Offline Support

- (NSString *)offlineBufferCachePath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cache = [paths objectAtIndex:0];
	NSString *SHKBufferPath = [cache stringByAppendingPathComponent:@"SHKBuffer"];
	
	// Check if the path exists, otherwise create it
	if (![fileManager fileExistsAtPath:SHKBufferPath]) {
		[fileManager createDirectoryAtPath:SHKBufferPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
	return SHKBufferPath;
}

- (BOOL)addBufferItemtoCache:(NSString *)uid withProfiles:(NSMutableArray *)profiles {
    
    
	return YES;
}

- (NSString *)offlineBufferQueueListPath {
	NSString *offlineQueuePathString = [[self offlineBufferCachePath] stringByAppendingPathComponent:@"SHKBufferOfflineQueue.plist"];
    return offlineQueuePathString;
}

- (NSMutableArray *)getOfflineQueueList {
	return [[[NSArray arrayWithContentsOfFile:[self offlineBufferQueueListPath]] mutableCopy] autorelease];
}

- (void)saveOfflineQueueList:(NSMutableArray *)queueList {
	[queueList writeToFile:[self offlineBufferQueueListPath] atomically:YES]; // TODO - should do this off of the main thread	
}


@end