/*
 
 File: ViewController.m
 Abstract: Implementation to create modal overlay such as "loading" dialog.
 Version: 1.0
 
 Created by Henry Algus on 06/08/14.
 Copyright (c) 2014 Henry ALgus. All rights reserved.
 
*/

#import "GlobalLoadingView.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mainWebView;
@synthesize reloadButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load url
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReturnCacheDataElseLoad timeoutInterval:15000];
    [mainWebView loadRequest:request];
    
    // initialize loading view
    globalLoadingView = [[GlobalLoadingView alloc] init];
    [globalLoadingView setLoadingTitle:@"Please wait"];
    [self.view addSubview:globalLoadingView.loadingDataView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)reloadWebView:(id)sender
{
    [mainWebView reload];
}

- (void)webViewDidStartLoad:(UIWebView *)articleWebView
{
    // load view when starting request
    [globalLoadingView.loadingDataView setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)articleWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [globalLoadingView.loadingDataView setHidden:YES];
}

- (void)webView:(UIWebView *)articleWebView didFailLoadWithError:(NSError *)error
{
    [globalLoadingView.loadingDataView setHidden:YES];
    
    // hide -999 errors
    if (error.code == NSURLErrorCancelled) {
        return;
    } else {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Error loading page"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
