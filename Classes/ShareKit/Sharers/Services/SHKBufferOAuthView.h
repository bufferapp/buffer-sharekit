//
//  SHKBufferOAuthView.h
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHKBufferOAuthView : UIViewController {
    id delegate;
	UIWebView *bufferOAuthWebView;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UIWebView *bufferOAuthWebView;

@end
