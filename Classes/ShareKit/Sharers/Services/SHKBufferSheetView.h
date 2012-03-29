//
//  SHKBufferSheetView.h
//  ShareKit
//
//  Created by Andrew Yates on 24/03/2012.
//  Copyright (c) 2012 Buffer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHKRequest.h"

@interface SHKBufferSheetView : UIViewController <UITextViewDelegate> {
    id delegate;
    UIScrollView *profileScrollView;
    UITextView *updateTextView;
    UILabel *updateCharLabel;
    SHKRequest *request;
    NSString *accessToken;
    
    NSMutableArray *profiles;
    NSMutableArray *selected_profiles;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UIScrollView *profileScrollView;
@property (nonatomic, retain) UITextView *updateTextView;
@property (nonatomic, retain) UILabel *updateCharLabel;
@property (nonatomic, retain) SHKRequest *request;
@property (nonatomic, retain) NSString *accessToken;

@property (nonatomic, retain) NSMutableArray *profiles;
@property (nonatomic, retain) NSMutableArray *selected_profiles;

-(id)initWithToken:(NSString *)token;

@end
