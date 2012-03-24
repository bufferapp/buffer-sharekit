//
//  SHKBufferOAuthView.h
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHK.h"
#import "SHKRequest.h"

@interface SHKBufferOAuthView : UIViewController <UIWebViewDelegate> {
    id delegate;
	UIWebView *bufferOAuthWebView;
    SHKRequest *request;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UIWebView *bufferOAuthWebView;
@property (nonatomic, retain) SHKRequest *request;

@end
