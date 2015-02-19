//
//  BBUSegmentTracker.h
//
//  Created by Boris Bügling on 19/02/15.
//

#import <Foundation/Foundation.h>

/** Simple Segment.io tracker client. */
@interface BBUSegmentTracker : NSObject

/**
 *  Initialize a new tracker.
 *
 *  @param token Segment.io write key to use.
 *
 *  @return A new tracker object.
 */
-(id)initWithToken:(NSString*)token;

/**
 *  Generate an URL request for a tracking event. This allows you to dispatch the event in any way
 *  you want by yourself. Events automatically use a persisted anonymous ID and include information
 *  about the user's operating system.
 *
 *  @param event      The event to track.
 *  @param properties The additional properties to attach to the event.
 *
 *  @return An URL request for sending the tracking event to Segment.io.
 */
-(NSURLRequest*)requestForTrackingEvent:(NSString*)event withProperties:(NSDictionary*)properties;

/**
 *  Convenience method for directly sending a tracking event.
 *
 *  @param event      The event to track.
 *  @param properties The additional properties to attach to the event.
 *  @param handler    An optional completion block for handling errors or reacting to successful
 *                    tracking events.
 */
-(void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;

@end
