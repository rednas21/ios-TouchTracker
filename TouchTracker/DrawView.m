//
//  DrawView.m
//  TouchTracker
//
//  Created by Sander Peerna on 7/6/15.
//  Copyright (c) 2015 Sander Peerna. All rights reserved.
//

#import "DrawView.h"
#import "Line.h"
#import "Circle.h"

@interface DrawView ()

@property (nonatomic, strong) NSMutableDictionary *circlesInProgress;
@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedFigures;

@end

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.circlesInProgress = [[NSMutableDictionary alloc] init];
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        
        self.finishedFigures = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
    }
    
    return self;
}

- (void)strokeLine:(Line*)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor blackColor] set];
    for (id figure in self.finishedFigures) {
        if ([figure isKindOfClass:[Line class]]) {
            Line *line = figure;
            [self strokeLine:line];
        } else if ([figure isKindOfClass:[Circle class]]) {
            Circle *circle = figure;
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(context, 5.0);
            CGContextAddEllipseInRect(context, circle.borderRect);
            CGContextStrokeEllipseInRect(context, circle.borderRect);
            CGContextFillPath(context);
        }
    }
    
    [[UIColor redColor] set];
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
    for (NSValue *key in self.circlesInProgress) {
        Circle *circle = self.circlesInProgress[key];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(context, 5.0);
        CGContextAddEllipseInRect(context, circle.borderRect);
        CGContextStrokeEllipseInRect(context, circle.borderRect);
        CGContextFillPath(context);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@\n", NSStringFromSelector(_cmd));
    
    if ([[event touchesForView:self] count] == 2) {
        CGPoint one = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        CGPoint two = [[[touches allObjects] objectAtIndex:1] locationInView:self];
        
        NSLog(@"(%f, %f) : (%f, %f)", one.x, one.y, two.x, two.y);
        
        Circle *circle = [[Circle alloc] init];
        circle.cornerOne = one;
        circle.cornerTwo = two;
        [circle doMath];
        
        NSLog(@"%f, %f, %f, %f", circle.centerX, circle.centerY, circle.radiusX, circle.radiusY);
        
        NSValue *key = [NSValue valueWithNonretainedObject:[[touches allObjects] objectAtIndex:0]];
        self.circlesInProgress[key] = circle;
    } else {
    
        for (UITouch *t in touches) {
    
            CGPoint location = [t locationInView:self];
    
            Line *line = [[Line alloc] init];
            line.begin = location;
            line.end = location;
        
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            self.linesInProgress[key] = line;
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@\n", NSStringFromSelector(_cmd));
    
    if ([[event touchesForView:self] count] == 2) {
        CGPoint one = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        CGPoint two = [[[touches allObjects] objectAtIndex:1] locationInView:self];
        
        NSLog(@"(%f, %f) : (%f, %f)", one.x, one.y, two.x, two.y);
        
        NSValue *key = [NSValue valueWithNonretainedObject:[[touches allObjects] objectAtIndex:0]];
        Circle *circle = self.circlesInProgress[key];
        
        circle.cornerOne = one;
        circle.cornerTwo = two;
        [circle doMath];
        
        NSLog(@"%f, %f, %f, %f", circle.centerX, circle.centerY, circle.radiusX, circle.radiusY);
    } else {
        for (UITouch *t in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            Line *line = self.linesInProgress[key];
        
            line.end = [t locationInView:self];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@\n", NSStringFromSelector(_cmd));
    
    if ([[event touchesForView:self] count] == 2) {
        CGPoint one = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        CGPoint two = [[[touches allObjects] objectAtIndex:1] locationInView:self];
        
        NSValue *key = [NSValue valueWithNonretainedObject:[[touches allObjects] objectAtIndex:0]];
        Circle *circle = self.circlesInProgress[key];
        
        circle.cornerOne = one;
        circle.cornerTwo = two;
        [circle doMath];
        
        NSLog(@"%f, %f, %f, %f", circle.centerX, circle.centerY, circle.radiusX, circle.radiusY);
        
        [self.finishedFigures addObject:circle];
        [self.circlesInProgress removeObjectForKey:key];
    } else {
        for (UITouch *t in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            Line *line = self.linesInProgress[key];
        
            [self.finishedFigures addObject:line];
            [self.linesInProgress removeObjectForKey:key];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@\n", NSStringFromSelector(_cmd));
    
    if ([[event touchesForView:self] count] == 2) {
        NSValue *key = [NSValue valueWithNonretainedObject:[[touches allObjects] objectAtIndex:0]];
        [self.circlesInProgress removeObjectForKey:key];
    } else {
        for (UITouch *t in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            [self.linesInProgress removeObjectForKey:key];
        }
    }
    
    [self setNeedsDisplay];
}

@end
