//
//  SHKBufferSheetView.m
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHKBufferSheetView.h"
#import "JSON.h"

@implementation SHKBufferSheetView

@synthesize profileScrollView, request, accessToken;

-(id)initWithToken:(NSString *)token {
    if (self) {
        self.title = @"Add to Buffer";
    }
    
    self.accessToken = token;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    CGRect scrollViewFrame = CGRectMake(0, 6, 320, 50);
    self.profileScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [self.view addSubview:profileScrollView];
    
    CGSize scrollViewContentSize = CGSizeMake(640, 460);
    [profileScrollView setContentSize:scrollViewContentSize];
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(200, 200, 50, 21)];
    [label setText:@"Hello"];
    [profileScrollView addSubview:label];
    
    [self getBufferProfiles];
}

-(void)getBufferProfiles {
        
        NSString *requestString = [NSString stringWithFormat:@"https://api.bufferapp.com/1/profiles.json?access_token=%@", self.accessToken];
        
        NSLog(@"request %@", requestString);
        
        self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:requestString]
                                                 params:nil
                                               delegate:self
                                     isFinishedSelector:@selector(loadBufferProfiles:)
                                                 method:@"GET"
                                              autostart:YES] autorelease];

}

-(void)loadBufferProfiles:(SHKRequest *)aRequest {
    NSDictionary *result = [[request getResult] JSONValue];
    
    if (aRequest.success)
    {
        // Do something with the result
        NSDictionary *result = [[aRequest getResult] JSONValue];
        
        
        NSLog(@"result %@", result);
        
    }
    
    // If there is an error, handle it
    else
    {
        // SHKRequest has a few properties that can help find out what happened
        // aRequest.response is the NSHTTPURLResponse of the request
        // aRequest.response.statusCode is the HTTTP status code of the response
        // [aRequest getResult] returns a NSString of the body of the response
        
        
        // What was the status code?
        int HTTPstatusCode = aRequest.response.statusCode; // 404? 401? 500?
        
        // What was the value of some header value?
        NSString *contentType = [aRequest.headers objectForKey:@"Content-Type"];
        
        NSLog(@"HTTPstatusCode %d, type %@", HTTPstatusCode, contentType);
    }
    
}



- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
