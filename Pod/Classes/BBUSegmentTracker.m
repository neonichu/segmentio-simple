//
//  BBUSegmentTracker.m
//
//  Created by Boris Bügling on 19/02/15.
//

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

#import "BBUSegmentTracker.h"

// Adapted from Segment iOS SDK, copyright (c) 2013 Segment Inc. friends@segment.com
static NSURL *SEGAnalyticsURLForFilename(NSString *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *supportPath = [paths firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:supportPath isDirectory:NULL]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:supportPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"error: %@", error.localizedDescription);
        }
    }
    return [NSURL fileURLWithPath:[supportPath stringByAppendingPathComponent:filename]];
}

static NSString *GenerateUUIDString() {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return UUIDString;
}

static NSString *GetAnonymousId(BOOL reset) {
    NSURL *url = SEGAnalyticsURLForFilename(@"segmentio.anonymousId");
    NSString *anonymousId = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    if (!anonymousId || reset) {
        anonymousId = GenerateUUIDString();
        [anonymousId writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    return anonymousId;
}

// Adapted from AFNetworking, copyright 2013-2014 AFNetworking (http://afnetworking.com)
static NSString *GetContext() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    return [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    return [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
}

#pragma mark -

@interface BBUSegmentTracker ()

@property (nonatomic) NSDateFormatter* iso8601Formatter;
@property (nonatomic) NSString* token;

@end

#pragma mark -

@implementation BBUSegmentTracker

-(instancetype)initWithToken:(NSString*)token {
    self = [super init];
    if (self) {
        self.iso8601Formatter = [NSDateFormatter new];
        [self.iso8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        [self.iso8601Formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];

        self.token = token;
    }
    return self;
}

-(NSURLRequest*)requestForTrackingEvent:(NSString*)event withProperties:(NSDictionary*)properties {
    NSURL* url = [NSURL URLWithString:@"https://api.segment.io/v1/track"];

    NSDictionary* payload = @{ @"userId": GetAnonymousId(NO),
                               @"event": event,
                               @"properties": properties,
                               @"context": @{ @"device": GetContext(),
                                              @"library": @{ @"name": @"segmentio-simple",
                                                             @"version": @"0.1.0" } },
                               @"timestamp": [self.iso8601Formatter stringFromDate:[NSDate new]] };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    NSData* authData = [[self.token stringByAppendingString:@":"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString* authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    return request;
}

-(void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler {
    if (!handler) {
        handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            id json = [NSJSONSerialization JSONObjectWithData:data
                                                      options:0
                                                        error:nil];

            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

            if (httpResponse.statusCode >= 400) {
                NSLog(@"Error sending tracking request: %@\n%@", error, json);
            }
        };
    }

    NSURLRequest* request = [self requestForTrackingEvent:event withProperties:properties];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:handler];
}

@end
