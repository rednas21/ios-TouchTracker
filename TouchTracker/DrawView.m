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

@interface DrawView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *moveRecognizer;
@property (nonatomic, strong) NSMutableDictionary *circlesInProgress;
@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedFigures;
@property (nonatomic, weak) Line *selectedLine;

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
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
    
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

- (id)figureAtPoint:(CGPoint)p
{
    for (id figure in self.finishedFigures) {
        if ([figure isKindOfClass:[Line class]]) {
            Line *line = figure;
            CGPoint start = line.begin;
            CGPoint end = line.end;
            
            // Check points on the line
            for (float t = 0.0; t <= 1.0; t += 0.05) {
                float x = start.x + t * (end.x - start.x);
                float y = start.y + t * (end.y - start.y);
                
                // Tapped point has to be withing 20 points of a line
                if (hypot(x - p.x, y - p.y) < 20.0) {
                    return line;
                }
            }
        }
    }
    
    // If nothing is close then don't select a line
    return nil;
}

- (void)deleteLine:(id)sender
{
    [self.finishedFigures removeObject:self.selectedLine];
    [self setNeedsDisplay];
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

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized tap.");
    
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self figureAtPoint:point];
    
    if (self.selectedLine) {
        // Become target of menu item action message
        [self becomeFirstResponder];
        
        // Get the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        // Create "Delete" menu item
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        // Tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        // Hide the menu if no line is selected
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
}

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized double tap.");
    
    [self.linesInProgress removeAllObjects];
    [self.circlesInProgress removeAllObjects];
    [self.finishedFigures removeAllObjects];
    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self figureAtPoint:point];
        
        if (self.selectedLine) {
            [self.linesInProgress removeAllObjects];
        }
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    
    [self setNeedsDisplay];
}

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    if (!self.selectedLine) {
        return;
    }
    
    if (gr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:self];
        
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
        [self setNeedsDisplay];
        
        [gr setTranslation:CGPointZero inView:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    
    return NO;
}

@end
