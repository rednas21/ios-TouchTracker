//
//  Circle.m
//  TouchTracker
//
//  Created by Sander Peerna on 7/8/15.
//  Copyright (c) 2015 Sander Peerna. All rights reserved.
//

#import "Circle.h"

@implementation Circle

- (void)doMath
{
    _centerX = MIN(_cornerOne.x, _cornerTwo.x);
    _centerY = MIN(_cornerOne.y, _cornerTwo.y);
    _radiusX = fabs(_cornerTwo.x - _cornerOne.x);
    _radiusY = fabs(_cornerTwo.y - _cornerOne.y);
    
    _borderRect = CGRectMake(_centerX, _centerY, _radiusX, _radiusY);
}

@end

