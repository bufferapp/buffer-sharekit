//
//  SHKBufferSheetView.h
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHKRequest.h"

@interface SHKBufferSheetView : UIViewController {
    UIScrollView *profileScrollView;
    SHKRequest *request;
    NSString *accessToken;
}

@property (retain, nonatomic) UIScrollView *profileScrollView;
@property (nonatomic, retain) SHKRequest *request;
@property (nonatomic, retain) NSString *accessToken;

-(id)initWithToken:(NSString *)token;

@end
