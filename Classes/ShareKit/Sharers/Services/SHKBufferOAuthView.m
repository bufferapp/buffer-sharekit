//
//  SHKBufferOAuthView.m
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHKBufferOAuthView.h"

@implementation SHKBufferOAuthView

@synthesize bufferOAuthWebView;


- (void)viewDidLoad {
    [super viewDidLoad];
	
    if(!bufferOAuthWebView){
        self.bufferOAuthWebView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
		bufferOAuthWebView.delegate = self;
		bufferOAuthWebView.scalesPageToFit = YES;
		self.bufferOAuthWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:bufferOAuthWebView];
    }
    
    NSURL *url = [NSURL URLWithString:@"https://bufferapp.com/oauth2/authorize?client_id=4f6db4dc512f7ec56f00000a&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"];
	
	[bufferOAuthWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
