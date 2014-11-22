/*
 
 File: FileUrlLoader.m
 Abstract: Implementation to effectively download and cache new files from the server while only checking modified date.
 Version: 1.0
 
 Created by Henry Algus on 06/08/14.
 
 */


#import <CommonCrypto/CommonDigest.h>
#import "FileUrlLoader.h"
#import "Reachability.h"

@interface FileUrlLoader ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation FileUrlLoader

// downloads file from the url and stores it according to parameters

- (NSData*) downloadFileFromUrl:(NSString*)urlString cacheFileName:(NSString*)cacheFileName localCacheTime:(NSInteger) localCacheTime {  
    
    
    NSURL *url = [NSURL URLWithString:urlString]; 
    NSData *data = nil;
    
    // Initialize cache paths
    
    NSString *cachedDigest = [self md5HexDigest:(cacheFileName == nil)?urlString:cacheFileName];
    
    NSString *cachedPath = [self getTempFilePath:cachedDigest cacheDirectoryPath:@"/var/cachedfiles"];
    NSFileManager *fileManager = [NSFileManager defaultManager];  
    
    BOOL downloadFromServer = NO;  
    BOOL forceCache = NO;
    NSString *lastModifiedString = nil;  
    NSDate *lastModifiedServer = nil;  
    NSDate *lastModifiedLocal = nil;
    
    // Initialize reachability to check for internet connection
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    
    // No network or bad network connection. Lets use cache instead.
    if (netStatus == NotReachable) {
        // do work here if the user has a valid connection
        forceCache = YES;
        downloadFromServer = NO;
        localCacheTime = 9999999;
        NSLog(@"No internet connection, forcing cache");
    }
    
    // file exists at cache path?
    if ([fileManager fileExistsAtPath:cachedPath]) {  
        NSError *error = nil;  
        // localcahe is 0, remove file from cache
        if(localCacheTime == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:cachedPath error:&error];
            if (error) {  
                NSLog(@"Error removing file from cache..");
            }
        } else {
            //NSLog(@"File exists %@",cachedPath);
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:cachedPath error:&error];  
        
            if (error) {  
                NSLog(@"Error reading file attributes for: %@ - %@", cachedPath, [error localizedDescription]);  
            }  
            lastModifiedLocal = [fileAttributes fileModificationDate];  
        }
    }  
    
    // check for forced cache
    if(lastModifiedLocal != nil) {
        // if last modified local is less than current date - force cache
        if([[lastModifiedLocal dateByAddingTimeInterval:localCacheTime] timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]){
            forceCache = YES;
            downloadFromServer = NO;
        }
    }
    


    
    // if cache is not forced, lets check for a update
    if(!forceCache) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // prepare for request and check for modified date
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:15000];
        
        [request setHTTPMethod:@"HEAD"];  
        NSHTTPURLResponse *response;  
        
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:nil];
        
        if(connection) {
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];  
            if ([response respondsToSelector:@selector(allHeaderFields)]) {  
                lastModifiedString = [[response allHeaderFields] objectForKey:@"Last-Modified"];  
            } 
            
        }
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // parse modified date
        @try {  
            NSDateFormatter *df = [[NSDateFormatter alloc] init];  
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";  
            df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];  
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  
            lastModifiedServer = [df dateFromString:lastModifiedString];  
            [df release];  
        }  
        @catch (NSException * e) {  
            NSLog(@"Error parsing last modified date: %@ - %@", lastModifiedString, [e description]);  
        }
        
        //NSLog(@"lastModifiedServer: %@", lastModifiedServer);  
        
        
        // Download file from server if we don't have a local file  
        if (!lastModifiedLocal) {  
            downloadFromServer = YES;  
        }  
        // Download file from server if the server modified timestamp is later than the local modified timestamp  
        if ([lastModifiedLocal laterDate:lastModifiedServer] == lastModifiedServer) {  
            downloadFromServer = YES;  
        } else {
            // update local timestamp to current
            if ([fileManager fileExistsAtPath:cachedPath]) { 
                [fileManager setAttributes: [NSDictionary dictionaryWithObject: [NSDate date] forKey: NSFileModificationDate] ofItemAtPath: cachedPath error: nil];
            }
        }
        
        if((lastModifiedServer == nil) && (response != nil)){
            downloadFromServer = YES;
        }
        
        if((lastModifiedServer == nil) && (response == nil)){
            downloadFromServer = NO;
        }
    }
    
    // download new file from server, otherwise read all the data from cache
    if (downloadFromServer) {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSData *data = [NSData dataWithContentsOfURL:url]; 
        if (data) {  
            // Save the data  
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSError *error = nil;  
            BOOL didWrite = [data writeToFile:cachedPath options:NSAtomicWrite error:&error];
            if (didWrite) {  
                //NSLog(@"Downloaded file saved to: %@", cachedPath);  
                // Set the file modification date to the timestamp from the server  
                if (lastModifiedServer) {  
                    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:lastModifiedServer forKey:NSFileModificationDate];  
                    NSError *error = nil;  
                    if ([fileManager setAttributes:fileAttributes ofItemAtPath:cachedPath error:&error]) {
                        NSLog(@"File modification date updated");
                    }
                    if (error) {  
                        NSLog(@"Error setting file attributes for: %@ - %@", cachedPath, [error localizedDescription]);  
                    }  
                } 
            }  
            
            if (error) {  
                NSLog(@"Error writing file: %@ - %@", cachedPath, [error localizedDescription]);  
            }  
            
            return data;
        }  
    } else {
       
        NSLog(@"Using cache");
        
        NSData *data = [NSData dataWithContentsOfFile:cachedPath];
        if(data) {
            return  data;
        }
    }
    // NSLog(@"Returning data %@",data);
    return data;
}

// Get temporary cache path. If directory does not exists, lets create

- (NSString *) getTempFilePath:(NSString*)cacheFileName cacheDirectoryPath:(NSString*)cacheDirectoryPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0]; 
    NSString *cacheDirName = [cacheDirectory stringByAppendingPathComponent:cacheDirectoryPath]; 
    NSFileManager *fileManager = [NSFileManager defaultManager]; 
    
    if (![fileManager fileExistsAtPath:cacheDirName]) {  
        NSError *error = nil;  
        [fileManager createDirectoryAtPath:cacheDirName withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {  
            NSLog(@"Error creating cache directory: %@ - %@", cacheDirName, [error localizedDescription]);  
        }  
        
    }
    
    NSString *filename = [cacheDirName stringByAppendingPathComponent:cacheFileName]; 
    return filename;
}


// Generate md5 string from input

-(NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    if(str == NULL){
        return @"";
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
