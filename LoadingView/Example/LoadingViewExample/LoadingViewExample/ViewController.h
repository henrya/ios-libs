/*
 
 File: ViewController.h
 Abstract: Implementation to create modal overlay such as "loading" dialog.
 Version: 1.0
 
 Created by Henry Algus on 06/08/14.
 Copyright (c) 2014 Henry ALgus. All rights reserved.
 
*/

#import <UIKit/UIKit.h>
#import "GlobalLoadingView.h"

@interface ViewController : UIViewController
{
    UIWebView *mainWebView;
    GlobalLoadingView *globalLoadingView;
}

@property (nonatomic, retain) IBOutlet UIWebView *mainWebView;
@property (nonatomic, retain) IBOutlet UIButton *reloadButton;
-(IBAction)reloadWebView:(id)sender;

@end
