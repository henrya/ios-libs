/*
 
 File: GlobalLoadingView.m
 Abstract: Implementation to create modal overlay such as "loading" dialog.
 Version: 1.0
 
 Created by Henry Algus on 06/08/14.
 Copyright (c) 2014 Henry ALgus. All rights reserved.
 
 */

// detect ipad
#define IS_IPAD ((([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))?YES:NO)
// loading box width
#define loadingDialogWidth 100
// loading box height
#define loadingDialogHeight 100
// loading box font size
#define loadingDialogFontSize 14
// loading box font size for iPad
#define loadingDialogFontSizeIpad 18

#import "GlobalLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GlobalLoadingView
@synthesize loadingDataView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// create loading message box

-(id)init
{
    if (self = [super init]) {
        int loadingWidth = loadingDialogWidth;
        int loadingHeight = loadingDialogHeight;
        int indicatorFontSize = loadingDialogFontSize;
        int indicatorType = UIActivityIndicatorViewStyleWhite;
        
        // use bigger dialog for iPad
        if(IS_IPAD){
            loadingWidth = loadingDialogWidth * 2;
            loadingHeight = loadingDialogHeight * 2;
            indicatorFontSize = loadingDialogFontSizeIpad;
            indicatorType = UIActivityIndicatorViewStyleWhiteLarge;
        }
        
        // create view
        loadingDataView = [[GlobalLoadingView alloc] initWithFrame:CGRectMake(0,0, [GlobalLoadingView windowWidth], [GlobalLoadingView windowHeight])];
        [loadingDataView setBackgroundColor:[UIColor clearColor]];
        
        // create spinner
        UIView *viewWithSpinner = [[UIView alloc] initWithFrame:CGRectMake([GlobalLoadingView windowWidth] / 2 - (loadingWidth / 2), [GlobalLoadingView windowHeight] / 2 - (loadingHeight / 2), loadingWidth, loadingHeight)];
        [viewWithSpinner.layer setCornerRadius:15.0f];
        viewWithSpinner.backgroundColor = [UIColor blackColor];
        [viewWithSpinner setAlpha:0.8f];
        UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, loadingWidth,loadingHeight / 4)];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorType];
        spinner.frame = CGRectMake((viewWithSpinner.frame.size.width - spinner.frame.size.width) / 2, (viewWithSpinner.frame.size.height - spinner.frame.size.height) / 2, spinner.bounds.size.width, spinner.bounds.size.height);
        
        [spinner startAnimating];
        
        // include message
        [msg setFont:[UIFont systemFontOfSize:indicatorFontSize]];
        [msg setTextAlignment:NSTextAlignmentCenter];
        [msg setTextColor:[UIColor whiteColor]];
        [msg setBackgroundColor:[UIColor clearColor]];
        [viewWithSpinner setOpaque:NO];
        viewWithSpinner.backgroundColor = [UIColor blackColor];
        [viewWithSpinner addSubview:spinner];
        [viewWithSpinner addSubview:msg];
        [loadingDataView addSubview:viewWithSpinner];
        [loadingDataView setHidden:YES];
    }
    return self;
}

// cycle through loadingview and look for title and change it

- (void)setLoadingTitle:(NSString *)loadingTitle {
    for (UIView *subview in loadingDataView.subviews) {
        for(UIView *insideView in subview.subviews) {
                if([insideView isKindOfClass:[UILabel class]]){
                    UILabel *label = (UILabel *) insideView;
                    [label setText:loadingTitle];
                }
        }
    }
}


// get current window height

+ (CGFloat) windowHeight   {
    return [UIScreen mainScreen].applicationFrame.size.height;
}

// get current window width

+ (CGFloat) windowWidth   {
    return [UIScreen mainScreen].applicationFrame.size.width;
}


@end
