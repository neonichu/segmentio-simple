//
//  segmentio-simpleTests.m
//  segmentio-simpleTests
//
//  Created by Boris Bügling on 02/19/2015.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <CCLRequestReplay/CCLRequestReplay.h>
#import <segmentio-simple/BBUSegmentTracker.h>

SpecBegin(SegmentSpecs)

describe(@"Tracker", ^{
    __block CCLRequestReplayManager* manager;
    __block BBUSegmentTracker* tracker;

    after(^{
        [manager stopReplay];
    });

    before(^{
        manager = [CCLRequestReplayManager new];
        tracker = [[BBUSegmentTracker alloc] initWithToken:@"#yolo"];
    });

    it(@"can track an event", ^{ waitUntil(^(DoneCallback done) {
        NSURLRequest* request = [tracker requestForTrackingEvent:@"some event"
                                                  withProperties:@{ @"heh": @YES }];

        [manager addRequest:request JSONResponseWithStatusCode:200 headers:@{} content:@{ @"success": @1 }];
        [manager replay];

        [tracker trackEvent:@"some event" withProperties:@{ @"heh": @YES }
          completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
              NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

              XCTAssertEqual(httpResponse.statusCode, 200);
              XCTAssertEqualObjects([NSJSONSerialization dataWithJSONObject:@{ @"success": @1 }
                                                                    options:0 error:nil], data);
              XCTAssertNil(connectionError);

              done();
        }];
    });
    });
});

SpecEnd
