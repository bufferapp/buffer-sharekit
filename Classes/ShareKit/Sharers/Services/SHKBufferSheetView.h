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
    UITextView *updateTextView;
    SHKRequest *request;
    NSString *accessToken;
    
    NSMutableArray *profiles;
    NSMutableArray *selected_profiles;
}

@property (retain, nonatomic) UIScrollView *profileScrollView;
@property (retain, nonatomic) UITextView *updateTextView;
@property (nonatomic, retain) SHKRequest *request;
@property (nonatomic, retain) NSString *accessToken;

@property (retain, nonatomic) NSMutableArray *profiles;
@property (retain, nonatomic) NSMutableArray *selected_profiles;

-(id)initWithToken:(NSString *)token;

@end
