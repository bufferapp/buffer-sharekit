//
//  SHKBufferOAuthView.m
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 Buffer, Inc. All rights reserved.
//

#import "SHKBufferOAuthView.h"
#import "JSON.h"

@implementation SHKBufferOAuthView

@synthesize bufferOAuthWebView, delegate, request;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Login";
	
    if(!bufferOAuthWebView){
        self.bufferOAuthWebView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
		bufferOAuthWebView.delegate = self;
		bufferOAuthWebView.scalesPageToFit = YES;
		self.bufferOAuthWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:bufferOAuthWebView];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    NSURL *url = [NSURL URLWithString:@"https://bufferapp.com/oauth2/authorize?client_id=4f6db4dc512f7ec56f00000a&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"];
	
	[bufferOAuthWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = request.URL;
    NSString *urlString = url.absoluteString;
    
    NSLog(@"urlString %@", urlString);
    
    if([urlString rangeOfString:@"redirect_uri"].location != NSNotFound){
        // Successful Signup
        NSLog(@"Success!!!!");
    } else if([urlString rangeOfString:@"access_denied"].location != NSNotFound) {
        // Show a screen warning user they need to allow
        NSLog(@"Should be hiding");
        [[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
    } else if([urlString rangeOfString:@"signup"].location != NSNotFound) {
        // Reset Webview back to Auth Page
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://bufferapp.com/oauth2/authorize?client_id=4f6db4dc512f7ec56f00000a&response_type=code"]];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [bufferOAuthWebView loadRequest:requestObj];
        
        // Open Signup page in Safari
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
    }
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *webViewTitle = [bufferOAuthWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    
    if ([webViewTitle rangeOfString:@"code"].location != NSNotFound) {
        NSString *code = [webViewTitle stringByReplacingOccurrencesOfString:@"Success code=" withString:@""];
        [self getAccessTokenWithCode:code];
    } else {
        //[oauthWebView setHidden:NO];
    }
}


-(void)getAccessTokenWithCode:(NSString *)code {
    
    NSString *requestPostString = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&client_id=4f6db4dc512f7ec56f00000a&client_secret=88eff43e8e2d11336975e28172db8929&redirect_uri=urn:ietf:wg:oauth:2.0:oob", code];
    
    self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.bufferapp.com/1/oauth2/token.json"]
                                             params:requestPostString
                                           delegate:self
                                 isFinishedSelector:@selector(accessTokenRecieved:)
                                             method:@"POST"
                                          autostart:YES] autorelease];
    
}


- (void)accessTokenRecieved:(SHKRequest *)aRequest {
    NSLog(@"request %@", [request getResult]);
    
    
    NSDictionary *result = [[request getResult] JSONValue];
    
    [self.delegate storeAccessToken:[result valueForKey:@"access_token"]];
    
}

- (void)cancel {
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
	[self.delegate sendDidCancel];
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[[SHK currentHelper] viewWasDismissed];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
