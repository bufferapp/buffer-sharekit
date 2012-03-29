//
//  SHKBufferSheetView.m
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 Buffer, Inc. All rights reserved.
//

#import "SHKBufferSheetView.h"
#import "SHK.h"
#import "JSON.h"

@implementation SHKBufferSheetView

@synthesize delegate, profileScrollView, updateTextView, updateCharLabel, request, accessToken, profiles, selected_profiles;

-(id)initWithToken:(NSString *)token {
    if (self) {
        self.title = @"Add to Buffer";
    }
    
    self.accessToken = token;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addBufferStatus)];
    
    
    CGRect scrollViewFrame = CGRectMake(0, 6, 320, 50);
    self.profileScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [self.view addSubview:profileScrollView];
    
    CGRect charLabelFrame = CGRectMake(255, 170, 57, 21);
    self.updateCharLabel = [[UILabel alloc] initWithFrame:charLabelFrame];
    self.updateCharLabel.textAlignment = UITextAlignmentRight;
    self.updateCharLabel.textColor = [UIColor darkGrayColor];
    self.updateCharLabel.text = @"";
    self.updateCharLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:updateCharLabel];
    
    CGRect updateTextFrame = CGRectMake(0, 57, 320, 105);
    self.updateTextView = [[UITextView alloc] initWithFrame:updateTextFrame];
    self.updateTextView.delegate = self;
    [self.view addSubview:updateTextView];
    
    [self.updateTextView setFont:[UIFont systemFontOfSize:13]];
    
    [self.updateTextView becomeFirstResponder];
    
    
    [profileScrollView setPagingEnabled:YES];
    [profileScrollView setShowsHorizontalScrollIndicator:NO];
    
    self.selected_profiles = [[NSMutableArray alloc] init];
    
    [self getBufferProfiles];
}

-(void)getBufferProfiles {
        
        NSString *requestString = [NSString stringWithFormat:@"https://api.bufferapp.com/1/profiles.json?access_token=%@", self.accessToken];
        
        self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:requestString]
                                                 params:nil
                                               delegate:self
                                     isFinishedSelector:@selector(loadBufferProfiles:)
                                                 method:@"GET"
                                              autostart:YES] autorelease];

}

-(void)loadBufferProfiles:(SHKRequest *)aRequest {
    if (aRequest.success) {
        // Do something with the result
        self.profiles = [[aRequest getResult] JSONValue];
        
        int buttonCount = 0;
        
        if([self.profiles count] != 0){
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
                [accountButton setAlpha:0.5];
                [accountButton setBackgroundColor:[UIColor clearColor]];
                [accountButton addTarget:self action:@selector(toggleAccount:) forControlEvents:UIControlEventTouchUpInside];
                
                
                NSString *avatar = [[profiles objectAtIndex:i] valueForKey:@"avatar"];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
                [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]]]];
                imageView.tag = (i + 1);
                imageView.userInteractionEnabled = NO;
                
                accountButton.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", [[self.profiles objectAtIndex:i] valueForKey:@"service_username"], [[profiles objectAtIndex:i] valueForKey:@"service"]];
                
                [accountButton addSubview:imageView];
                
                
                UIImageView *networkIcon = [[UIImageView alloc] initWithFrame:CGRectMake(31, 31, 13, 13)];
                
                networkIcon.userInteractionEnabled = NO;
                
                if([[[self.profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"twitter"]){
                    [networkIcon setImage:[UIImage imageNamed:@"twitter-icon.png"]];
                }
                
                if([[[self.profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"facebook"]){
                    [networkIcon setImage:[UIImage imageNamed:@"facebook-icon.png"]];
                }
                
                if([[[self.profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"gplus"]){
                    [networkIcon setImage:[UIImage imageNamed:@"gplus-icon.png"]];
                }
                
                if([[[profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"linkedin"]){
                    [networkIcon setImage:[UIImage imageNamed:@"linkedin-icon.png"]];
                }
                
                [accountButton addSubview:networkIcon];
                
                [profileScrollView addSubview:accountButton];
                
                
                // Select Default Profiles
                if([[[[self.profiles objectAtIndex:i] valueForKey:@"default"] stringValue] isEqualToString:@"1"]){
                    
                    [self.selected_profiles addObject:[[self.profiles objectAtIndex:i] valueForKey:@"id"]];
                    
                    [accountButton setAlpha:1.0];
                    UIImage *buttonImage = [UIImage imageNamed:@"avatar-active.png"];
                    [accountButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
                }
            }
            
            
            if(self.profiles.count <= 6){
                profileScrollView.contentSize = CGSizeMake(320, 44);
            } else {
                profileScrollView.contentSize = CGSizeMake(320 * ceil((float)profiles.count / 6), 44);
            }
            
            [self detectTwitterAccountActive];
            
        } else {
            
        }
    } else {
        int HTTPstatusCode = aRequest.response.statusCode; // 404? 401? 500?
        NSString *contentType = [aRequest.headers objectForKey:@"Content-Type"];
        NSLog(@"HTTPstatusCode %d, type %@", HTTPstatusCode, contentType);
    }
}



-(void)toggleAccount:(id)sender {
    NSString *accountString = [NSString stringWithFormat:@"%d", ([sender tag] - 1)];
    int accountTag = [accountString intValue];
    
    if([self.selected_profiles indexOfObject:[[self.profiles objectAtIndex:accountTag] valueForKey:@"id"]] != NSNotFound){
        [self.selected_profiles removeObjectAtIndex:[self.selected_profiles indexOfObject:[[self.profiles objectAtIndex:accountTag] valueForKey:@"id"]]];
        [sender setAlpha:0.5];
        [sender setBackgroundImage:nil forState:UIControlStateNormal];
    } else {
        [self.selected_profiles addObject:[[self.profiles objectAtIndex:accountTag] valueForKey:@"id"]];
        [sender setAlpha:1.0];
        UIImage *buttonImage = [UIImage imageNamed:@"avatar-active.png"];
        [sender setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    
    [self detectTwitterAccountActive];
}



- (void)textViewDidChange:(UITextView *)textView {
	self.updateCharLabel.text = [NSString stringWithFormat:@"%d", 140 - [updateTextView.text length]];
    
    [self detectLinksAndUpdateCharactersRemaining];
}



-(void)detectLinksAndUpdateCharactersRemaining {
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:updateTextView.text options:0 range:NSMakeRange(0, [updateTextView.text length])];
    
    if([matches count] != 0){
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                NSString *urlString = [NSString stringWithFormat:@"%@", url];
                
                // Add urlString Character Count to the character count & remove 20
                self.updateCharLabel.text = [NSString stringWithFormat:@"%d", 140 - [updateTextView.text length] + [urlString length] - 20];
                
            }
        }
    }
}




-(void)detectTwitterAccountActive {
    if([self twitterAccountActive]){
        [self.updateCharLabel setHidden:NO];
    } else {
        [self.updateCharLabel setHidden:YES];
    }
}

-(BOOL)twitterAccountActive {
    for (NSString * profile_id in self.selected_profiles) {
        for (NSMutableArray* profile in self.profiles) {
            NSString *_id = [profile valueForKey:@"id"];
            
            if([_id isEqualToString:profile_id]){ 
                NSString *service = [profile valueForKey:@"service"];
                
                if([service isEqualToString:@"twitter"]){ 
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}





-(void)addBufferStatus {
    if([self.selected_profiles count] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Profiles Selected"
                                                        message: @"Select profile(s) to add this update to."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    } else if([updateTextView.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No update content"
                                                        message: @"Please add some content to this update."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    } else if([self twitterAccountActive] && [updateTextView.text length] > 140){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Update too long"
                                                        message: @"Please reduce the number of characters."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        [self postBufferUpdate];
    }
}


-(void)postBufferUpdate {
    
    [updateTextView resignFirstResponder];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Posting...")];
    
    [self.delegate postBufferUpdate:updateTextView.text toProfiles:self.selected_profiles];
     
}

- (void)cancel {
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
	[self.delegate sendDidCancel];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
