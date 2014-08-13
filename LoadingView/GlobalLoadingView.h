/*
 
 File: GlobalLoadingView.h
 Abstract: Implementation to create modal overlay such as "loading" dialog.
 Version: 1.0
 
 Created by Henry Algus on 06/08/14.
 Copyright (c) 2014 Henry ALgus. All rights reserved.
 
*/

#import <UIKit/UIKit.h>

@interface GlobalLoadingView : UIView
@property(nonatomic,retain)NSString *loadingTitle;
@property(nonatomic,retain)UILabel *msg;
@property(nonatomic,retain)GlobalLoadingView *loadingDataView;

-(id)init;
-(void)setLoadingTitle:(NSString *)loadingTitle;
+ (CGFloat) windowHeight;
+ (CGFloat) windowWidth;

@end
