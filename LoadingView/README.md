LoadingView
==========

Implementation to display loading style modal dialogs. You can display only dialog or you can also add optional message.
You can also download simple example, which is using LoadingView in UIWebView context - LoadingView is displayed when content is loaded.

How to use?
--------------

At first you should import "GlobalLoadingView.h"

`#import "GlobalLoadingView.h"`

and in your implementation you should initialize LoadingView like this:

`
globalLoadingView = [[GlobalLoadingView alloc] init];
[globalLoadingView setLoadingTitle:@"Please wait"];
[self.view addSubview:globalLoadingView.loadingDataView];

` 

To hide LoadingView, you can just set object state to hidden

`[globalLoadingView.loadingDataView setHidden:YES];`

And to show it again, you can set object state to visible

`[globalLoadingView.loadingDataView setHidden:NO];`
