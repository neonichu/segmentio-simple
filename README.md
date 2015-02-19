# segmentio-simple

[![CI Status](http://img.shields.io/travis/neonichu/segmentio-simple.svg?style=flat)](https://travis-ci.org/neonichu/segmentio-simple)
[![Version](https://img.shields.io/cocoapods/v/segmentio-simple.svg?style=flat)](http://cocoadocs.org/docsets/segmentio-simple)
[![License](https://img.shields.io/cocoapods/l/segmentio-simple.svg?style=flat)](http://cocoadocs.org/docsets/segmentio-simple)
[![Platform](https://img.shields.io/cocoapods/p/segmentio-simple.svg?style=flat)](http://cocoadocs.org/docsets/segmentio-simple)

## Usage

This is a very minimal library for interacting with [Segment](http://segment.com), which is useful when you only want server-side
integrations. In contrast to the official SDK, it also supports OS X.

Just pass your write-token and start tracking events with custom properties like this:

```objectivec
[[[BBUSegmentTracker alloc] initWithToken:@"segmentio-token"] trackEvent:@"#yolo"
                                                          withProperties:@{ @"yep": @23 }
                                                       completionHandler:nil];
```

## Installation

segmentio-simple is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "segmentio-simple"

## Author

Boris Bügling, boris@buegling.com

## License

segmentio-simple is available under the MIT license. See the LICENSE file for more info.
