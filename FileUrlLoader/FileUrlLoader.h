/*
 
 File: FileUrlLoader.h
 Abstract: Implementation to effectively download and cache new files from the server while only checking modified date.
 Version: 1.0
 
 Created by Henry Algus on 06/08/14.
 
 */

#import <Foundation/Foundation.h>

@interface FileUrlLoader : NSObject
- (NSData*) downloadFileFromUrl:(NSString*)urlString cacheFileName:(NSString*)cacheFileName localCacheTime:(NSInteger) localCacheTime ; 
- (NSString *) getTempFilePath:(NSString*)cacheFileName cacheDirectoryPath:(NSString*)cacheDirectoryPath;
- (NSString*) md5HexDigest:(NSString*)input;
@end
