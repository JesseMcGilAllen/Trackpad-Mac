//
//  ScrollWheelHandler.m
//  Trackpad Mac
//
//  Created by Jesse McGil Allen on 5/1/15.
//  Copyright (c) 2015 Jesse McGil Allen. All rights reserved.
//

#import "ScrollWheelHandler.h"
@import CoreGraphics;

@implementation ScrollWheelHandler

+(void)scrollUsingPoint:(CGPoint) point {
    
    int wheelCount = 2;
    int scrollX = point.x;
    int scrollY = point.y;
    
    CGEventRef scrollWheelEvent = CGEventCreateScrollWheelEvent(NULL, kCGScrollEventUnitPixel, wheelCount, scrollY, scrollX);
    
    CGEventPost(kCGHIDEventTap, scrollWheelEvent);
    
    CFRelease(scrollWheelEvent);
    
}

@end
