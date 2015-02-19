//
//  BBUViewController.m
//  segmentio-simple
//
//  Created by Boris Bügling on 02/19/2015.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <segmentio-simple/BBUSegmentTracker.h>

#import "BBUViewController.h"

@interface BBUViewController ()

@end

@implementation BBUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[[BBUSegmentTracker alloc] initWithToken:@"segmentio-token"] trackEvent:@"#yolo"
                                                              withProperties:@{ @"yep": @23 }
                                                           completionHandler:nil];
}

@end
