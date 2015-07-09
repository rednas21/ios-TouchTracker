//
//  Circle.h
//  TouchTracker
//
//  Created by Sander Peerna on 7/8/15.
//  Copyright (c) 2015 Sander Peerna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Circle : NSObject

@property (nonatomic) CGRect borderRect;
@property (nonatomic) CGPoint cornerOne;
@property (nonatomic) CGPoint cornerTwo;
@property (nonatomic) double centerX, centerY, radiusX, radiusY;

- (void)doMath;

@end
