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

@synthesize delegate, profileScrollView, updateTextView, updateCharLabel, request, accessToken, profiles, selected_profiles, updateCopy;

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
    
    CGRect scrollViewFrame;
    CGRect charLabelFrame;
    CGRect updateTextFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        scrollViewFrame = CGRectMake(0, 6, 650, 50);
        charLabelFrame = CGRectMake(584, 264, 57, 21);
        updateTextFrame = CGRectMake(0, 60, 650, 138);
    } else {
        scrollViewFrame = CGRectMake(0, 6, 320, 50);
        charLabelFrame = CGRectMake(255, 170, 57, 21);
        updateTextFrame = CGRectMake(0, 57, 320, 105);
    }
    
    self.profileScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [self.view addSubview:profileScrollView];
    
    self.updateCharLabel = [[UILabel alloc] initWithFrame:charLabelFrame];
    self.updateCharLabel.textAlignment = UITextAlignmentRight;
    self.updateCharLabel.textColor = [UIColor darkGrayColor];
    self.updateCharLabel.text = @"";
    self.updateCharLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:updateCharLabel];
    
    
    self.updateTextView = [[UITextView alloc] initWithFrame:updateTextFrame];
    self.updateTextView.delegate = self;
    [self.view addSubview:updateTextView];
    
    [self.updateTextView setFont:[UIFont systemFontOfSize:13]];
    
    
    self.updateTextView.text = updateCopy;
    
    [self.updateTextView becomeFirstResponder];
    
    
    [profileScrollView setPagingEnabled:YES];
    [profileScrollView setShowsHorizontalScrollIndicator:NO];
    
    self.selected_profiles = [[NSMutableArray alloc] init];
    
    [self getBufferProfiles];
    [self shortenLinks];
}


-(void)updateFrames{
	CGSize size = self.view.frame.size;
    
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
        self.profileScrollView.frame = CGRectMake(0, 6, size.width, 50);
        self.updateCharLabel.frame = CGRectMake(size.width - 57 - 8, 170, 57, 21);
        self.updateTextView.frame = CGRectMake(0, 57, size.width, size.height);
        
    }
     */
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
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    if(i == 0) {
                        frame.origin.x = 10;
                    } else if(i % 12 == 0){
                        frame.origin.x = (650 * (i / 12)) + 10;
                        buttonCount = 0;
                    } else {
                        buttonCount++;
                        frame.origin.x = ((650 * floor(i / 12)) + (52.7 * buttonCount) + 15);
                    }
                } else {
                    if(i == 0) {
                        frame.origin.x = 7;
                    } else if(i % 6 == 0){
                        frame.origin.x = (320 * (i / 6)) + 7;
                        buttonCount = 0;
                    } else {
                        buttonCount++;
                        frame.origin.x = ((320 * floor(i / 6)) + (52.7 * buttonCount) + 7);
                    }
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
                    [networkIcon setImage:[UIImage imageNamed:@"shkbuffer-twitter-icon.png"]];
                }
                
                if([[[self.profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"facebook"]){
                    [networkIcon setImage:[UIImage imageNamed:@"shkbuffer-facebook-icon.png"]];
                }
                
                if([[[self.profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"gplus"]){
                    [networkIcon setImage:[UIImage imageNamed:@"shkbuffer-gplus-icon.png"]];
                }
                
                if([[[profiles objectAtIndex:i] valueForKey:@"service"] isEqualToString:@"linkedin"]){
                    [networkIcon setImage:[UIImage imageNamed:@"shkbuffer- linkedin-icon.png"]];
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
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if(self.profiles.count <= 12){
                    profileScrollView.contentSize = CGSizeMake(650, 44);
                } else {
                    profileScrollView.contentSize = CGSizeMake(650 * ceil((float)self.profiles.count / 12), 44);
                }
            } else {
                if(self.profiles.count <= 6){
                    profileScrollView.contentSize = CGSizeMake(320, 44);
                } else {
                    profileScrollView.contentSize = CGSizeMake(320 * ceil((float)profiles.count / 6), 44);
                }
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



-(int)detectLinksAndUpdateCharactersRemaining {
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:updateTextView.text options:0 range:NSMakeRange(0, [updateTextView.text length])];
    
	int remaining = 140 - [updateTextView.text length];
	
    if([matches count] != 0){
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                NSString *urlString = [NSString stringWithFormat:@"%@", url];
                
                // Add urlString Character Count to the character count & remove 20
				remaining = remaining + [urlString length] - 20;
                self.updateCharLabel.text = [NSString stringWithFormat:@"%d", remaining];
                
            }
        }
    }
	
	return remaining;
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
    } else if([self twitterAccountActive] && [self detectLinksAndUpdateCharactersRemaining] < 0){
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



-(void)shortenLinks {
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:updateTextView.text options:0 range:NSMakeRange(0, [updateTextView.text length])];
    
    if([matches count] != 0){
        [[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Shortening Links")];
        
        
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                
                NSURL *url = [match URL];
                NSString *urlString = [NSString stringWithFormat:@"%@", url];
                urlString = [urlString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                urlString = [urlString stringByReplacingOccurrencesOfString:@"Http://" withString:@""];
                
                NSString *requestUrl = [NSString stringWithFormat:@"http://api.bufferapp.com/1/updates/shorten.json?access_token=%@&url=%@", self.accessToken, urlString];
                
                self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]
                                                         params:nil
                                                       delegate:self
                                             isFinishedSelector:@selector(linkShortened:)
                                                         method:@"GET"
                                                      autostart:YES] autorelease];
            }
        }
        
    } else {
        // No Links
    }
}



-(void)linkShortened:(SHKRequest *)aRequest {
    [[SHKActivityIndicator currentIndicator] hide];
    
    NSLog(@"Shortened");
    
    if (aRequest.success) {
        NSLog(@"request %@", request.response);
        
        // Notify delegate
        //[self sendDidFinish];
    } else {
        //[self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem adding to Buffer.")]];
    }
}








- (void)cancel {
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
	[self.delegate sendDidCancel];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self updateFrames];
	[self detectLinksAndUpdateCharactersRemaining];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
