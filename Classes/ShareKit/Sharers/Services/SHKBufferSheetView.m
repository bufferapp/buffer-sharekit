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
    
    [profileScrollView setPagingEnabled:YES];
    
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
    
    if (aRequest.success) {
        // Do something with the result
        NSMutableArray *profiles = [[aRequest getResult] JSONValue];
        
        int buttonCount = 0;
        
        if([profiles count] != 0){
            for (int i = 0; i < profiles.count; i++) {
                CGRect frame;
                
                if(i == 0) {
                    frame.origin.x = 7;
                } else if(i % 6 == 0){
                    frame.origin.x = (320 * (i / 6)) + 7;
                    buttonCount = 0;
                } else {
                    buttonCount++;
                    frame.origin.x = ((320 * floor(i / 6)) + (52.7 * buttonCount) + 7);
                }
                
                frame.origin.y = 0;
                frame.size = CGSizeMake(44, 49);
                
                // Create Button
                UIButton *accountButton = [UIButton buttonWithType:UIButtonTypeCustom];
                accountButton.frame = frame;
                accountButton.tag = (i + 1);
                [accountButton setAlpha:0.7];
                [accountButton setBackgroundColor:[UIColor clearColor]];
                [accountButton addTarget:self action:@selector(toggleAccount:) forControlEvents:UIControlEventTouchUpInside];
                
                
                NSString *avatar = [[profiles objectAtIndex:i] valueForKey:@"avatar"];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
                [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]]]];
                imageView.tag = (i + 1);
                imageView.userInteractionEnabled = NO;
                
                accountButton.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", [[profiles objectAtIndex:i] valueForKey:@"service_username"], [[profiles objectAtIndex:i] valueForKey:@"service"]];
                
                [accountButton addSubview:imageView];
                
                
                UIImageView *networkIcon = [[UIImageView alloc] initWithFrame:CGRectMake(31, 31, 13, 13)];
                
                networkIcon.userInteractionEnabled = NO;
                
                if([[[profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"twitter"]){
                    [networkIcon setImage:[UIImage imageNamed:@"twitter-icon.png"]];
                }
                
                if([[[profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"facebook"]){
                    [networkIcon setImage:[UIImage imageNamed:@"facebook-icon.png"]];
                }
                
                if([[[profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"gplus"]){
                    [networkIcon setImage:[UIImage imageNamed:@"gplus-icon.png"]];
                }
                
                if([[[profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"linkedin"]){
                    [networkIcon setImage:[UIImage imageNamed:@"linkedin-icon.png"]];
                }
                
                [accountButton addSubview:networkIcon];
                
                [profileScrollView addSubview:accountButton];
                
                
                /*
                // Select Default Profiles
                if([[[[profiles objectAtIndex:i] valueForKey:@"default"] stringValue] isEqualToString:@"1"]){
                    
                    [self.selected_profiles addObject:[[self.profiles objectAtIndex:i] valueForKey:@"id"]];
                    
                    [accountButton setAlpha:1.0];
                    UIImage *buttonImage = [UIImage imageNamed:@"avatar-active.png"];
                    [accountButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
                    
                    if([self.selected_profiles count] != 1){
                        bufferProfilesLabel.text = [NSString stringWithFormat:@"%d Profiles selected.", [self.selected_profiles count]];
                    } else {
                        bufferProfilesLabel.text = @"1 Profile selected.";
                    }
                }
                 */
            }
            
            
            if(profiles.count <= 6){
                profileScrollView.contentSize = CGSizeMake(320, 44);
            } else {
                profileScrollView.contentSize = CGSizeMake(320 * ceil((float)profiles.count / 6), 44);
            }
            
        } else {
            
        }
        
        NSLog(@"result %@", result);
        
    } else {
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
