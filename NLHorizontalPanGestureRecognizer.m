//
//  NLHorizontalPanGestureRecognizer.h.m
//  QH360CameraES
//
//  Created by wanglongxiang on 2018/12/16.
//  Copyright © 2018年 360. All rights reserved.
//

#import "NLHorizontalPanGestureRecognizer.h.h"
#import <UIKit/UIGestureRecognizerSubClass.h>

@implementation NLHorizontalPanGestureRecognizer.h
{
    BOOL _locked;
    CGPoint _startPoint;
    CGPoint _lastPoint;
    CGFloat _speed;
    NSTimeInterval _lastTouchTime;
    UITouch * _touch;
}

- (CGPoint)locationInView:(UIView *)view
{
    if (_touch == nil) {
        return CGPointZero;
    }
    return [_touch locationInView:view];
}

- (void)reset {
    _locked = NO;
    _startPoint = CGPointZero;
    _lastPoint = CGPointZero;
    _speed = 0;
    _lastTouchTime = 0;
}


- (BOOL)ignoreMutiTouch:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count > 1) {
        self.state = UIGestureRecognizerStateFailed;
        
        [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
            [self ignoreTouch:touch forEvent:event];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self ignoreMutiTouch:touches withEvent:event])
        return;
    _touch = [touches anyObject];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self ignoreMutiTouch:touches withEvent:event])
        return;
    
    _touch = [touches anyObject];
    
    CGPoint previousLocation = [_touch previousLocationInView:self.view];
    CGPoint location = [_touch locationInView:self.view];
    
    if (!_locked) {
        if (ABS(location.x - previousLocation.x) > ABS(location.y - previousLocation.y)) {
            self.state = UIGestureRecognizerStateBegan;
            _locked = YES;
            _startPoint = location;
            _lastPoint = location;
            _speed = 0;
            _lastTouchTime = _touch.timestamp;
        } else {
            self.state = UIGestureRecognizerStateFailed;
            [self ignoreTouch:_touch forEvent:event];
            
            return;
        }
    } else {
        self.state = UIGestureRecognizerStateChanged;
        _speed = (location.x - _lastPoint.x) / (_touch.timestamp - _lastTouchTime);
        _lastTouchTime = _touch.timestamp;
        _startPoint = _lastPoint;
        _lastPoint = location;
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self ignoreMutiTouch:touches withEvent:event])
        return;
    
    if (_locked) {
        _locked = NO;
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
        [self ignoreTouch:[touches anyObject] forEvent:event];
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self ignoreMutiTouch:touches withEvent:event])
        return;
    
    if (_locked) {
        _locked = NO;
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateFailed;
        [self ignoreTouch:[touches anyObject] forEvent:event];
    }
    
    [super touchesCancelled:touches withEvent:event];
}


- (CGFloat)distance {
    return _lastPoint.x - _startPoint.x;
}

- (CGFloat)speed {
    return _speed;
}
@end
