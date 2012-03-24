//
//  ViewController.h
//  BufferShareKit
//
//  Created by Andrew Yates on 23/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    IBOutlet UIButton *shareBtn;
}

@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

-(IBAction)share:(id)sender;

@end
