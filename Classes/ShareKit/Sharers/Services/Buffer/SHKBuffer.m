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
#import "NSString+Encode.h"
#import "JSONKit.h"

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

- (BOOL)tryToSend {
    // Grab item from Buffer queue
    NSMutableArray *buffer_item = [self getBufferQueueItemForKey:item.title];
    
    // Post Update
    [self postBufferUpdate:[buffer_item valueForKey:@"update"] toProfiles:[buffer_item valueForKey:@"profiles"]];
    
    // Remove item from Buffer Queue
    NSMutableArray *buffer_queue = [self getOfflineBufferQueueList];
    [buffer_queue removeObjectIdenticalTo:buffer_item];
    [self saveOfflineBufferQueueList:buffer_queue];
    
    return YES;
}


-(NSMutableArray *)getBufferQueueItemForKey:(NSString *)needle_key {
    NSMutableArray *queue_items = [self getOfflineBufferQueueList];
    
    for (NSMutableArray* queue_item in queue_items) {
        
        NSString *haystack_key = [queue_item valueForKey:@"sid"];
        
		if([haystack_key isEqualToString:needle_key]){ 
			return queue_item;
		}
	}
	return FALSE;
    
}


-(BOOL)send {
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
        
        NSString *formatted_update = [updateText encodeString:NSUTF8StringEncoding];
        
        NSString *postParams = [NSString stringWithFormat:@"text=%@&shorten=true&profile_ids[]=%@", formatted_update, [profiles componentsJoinedByString:@"&profile_ids[]="]];
        
        
        self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:postUrl]
                                                 params:postParams
                                               delegate:self
                                     isFinishedSelector:@selector(updatePosted:)
                                                 method:@"POST"
                                              autostart:YES] autorelease];
    } else if ([[self class] canShareOffline]) {
        // Change the item title to a unique string used to match both items in ShareKit's queue and the Buffer Queue
        NSString *sid = [NSString stringWithFormat:@"%i-%i", [[NSDate date] timeIntervalSince1970], arc4random()];
        
        item.title = sid;
        
        [self addBufferItemtoCache:sid withUpdate:updateText withProfiles:profiles];
        [SHK addToOfflineQueue:item forSharer:[self sharerId]];
        
        [self sendDidFinish];
    }
}

-(void)updatePosted:(SHKRequest *)aRequest {
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    if (aRequest.success) {
        NSMutableDictionary *response = [aRequest.getResult objectFromJSONString];
        
        if([[[response valueForKey:@"success"] stringValue] isEqualToString:@"1"]){
            [self sendDidFinish];
        } else {
            [self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem adding to Buffer.")]];
        }
    } else {
        NSMutableDictionary *response = [aRequest.getResult objectFromJSONString];
        if([response valueForKey:@"message"]){
            [self sendDidFailWithError:[SHK error:[response valueForKey:@"message"]]];
        } else {
            [self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem adding to Buffer.")]];
        }
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

- (void)addBufferItemtoCache:(NSString *)sid withUpdate:(NSString *)update withProfiles:(NSMutableArray *)profiles {
    
    // Open queue list
	NSMutableArray *queueList = [self getOfflineBufferQueueList];
	if (queueList == nil)
		queueList = [NSMutableArray arrayWithCapacity:0];
	
	// Add to queue list
	[queueList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          sid,@"sid",
                          update,@"update",
                          profiles,@"profiles",
                          nil]];
	
	[self saveOfflineBufferQueueList:queueList];
}

- (NSString *)offlineBufferQueueListPath {
	NSString *offlineQueuePathString = [[self offlineBufferCachePath] stringByAppendingPathComponent:@"SHKBufferOfflineQueue.plist"];
    return offlineQueuePathString;
}

- (NSMutableArray *)getOfflineBufferQueueList {
	return [[[NSArray arrayWithContentsOfFile:[self offlineBufferQueueListPath]] mutableCopy] autorelease];
}

- (void)saveOfflineBufferQueueList:(NSMutableArray *)queueList {
	[queueList writeToFile:[self offlineBufferQueueListPath] atomically:YES]; // TODO - should do this off of the main thread	
}


@end