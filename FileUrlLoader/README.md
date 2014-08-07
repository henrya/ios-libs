FileUrlLoader
==========

Small implementation to download new files from the internet and storing retrieved data in internal cache while only checking for modified date in response headers. Next time when the application tries to download file again, only cache is used if server modified date is not changed. 

This is much faster than downloading file, checking for the checkmum and then storing this file in the cache, if necessary.

Additionaly, this implementation is using Apple reachability example to check for the connection state.
Reachability documentation is available here: https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html

How to use?
--------------

Just import FileUrlLoader.h to your file and call for method downloadFileFromUrl

Example:

    NSData *downloadedData = [urLoader downloadFileFromUrl:@"http://www.example.com/image.jpg" cacheFileName:@"image.jpg" localCacheTime:9999];

Additional parameters are as follows:

cacheFileName: file name to store in local cache.
localCacheTime: how long time the cache will kept, until it will be refreshed again. Use "0", to disable cachhe.

