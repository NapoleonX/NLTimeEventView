//
//  NLTimeEventView.m
//  QH360CameraES
//
//  Created by wanglongxiang on 2018/12/13.
//  Copyright © 2018年 360. All rights reserved.
//

#import "NLTimeEventView.h"
#import "NLHorizontalPanGestureRecognizer.h.h"
#define SCALE_SPACE 3.f // 每隔刻度实际长度4个点

#define LABEL_HEIGHT 0.1

#define SCALE_HEIGHT 0.52

#define INDICATOR_HEIGHT 5

@implementation NLEventInfo

@end

@interface NLTimeEventView()

@end

@implementation NLTimeEventView
{
    NSTimeInterval _baseTimeInterval;
    NSCalendar * _calendar;
    
    NSMutableSet *_secondRanges;
    NSMutableSet *_mintuteRanges;
    NSMutableSet *_hourRanges;
    NSMutableSet *_dayRanges;
    
    CGFloat secondScaleTop;
    CGFloat fiveSecondScaleTop;
    CGFloat thirtySecondScaleTop;
    CGFloat minuteScaleTop;
    CGFloat fiveMinuteScaleTop;
    CGFloat thirtyMinuteScaleTop;
    CGFloat hourScaleTop;
    CGFloat twelveHourScaleTop;
    CGFloat dayScaleTop;
    CGFloat firstDayScaleTop;
    CGFloat monthScaleTo;
    CGFloat yearScaleTop;
    
    NSCalendarUnit unitFlags;
    NSInteger timeFactor;
    NSString * format;
    
    BOOL _dragLock;
}

+ (Class)layerClass
{
    return [CAScrollLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    _calendar.timeZone = [NSTimeZone systemTimeZone];
    _secondRanges = [NSMutableSet set];
    _mintuteRanges = [NSMutableSet set];
    _hourRanges = [NSMutableSet set];
    _dayRanges = [NSMutableSet set];
    _dragLock = NO;
    
    self.backgroundColor = [UIColor colorWithRGB:@"#323236"];

    self.layer.masksToBounds = YES;
    ((CAScrollLayer *)self.layer).scrollMode = @"horizontally";
    NLHorizontalPanGestureRecognizer.h *recognizer = [[NLHorizontalPanGestureRecognizer.h alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

}


- (void)setCurrentTimeInterval:(NSTimeInterval)timeInterval
{
    if (_dragLock) {
        return;
    }
    _baseTimeInterval = timeInterval;
    [self setNeedsDisplay];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
 
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        _dragLock = YES;
    }else
    {
        _dragLock = NO;
    }

    CGPoint offset = [recognizer translationInView:self];
    CGPoint point = self.bounds.origin;
    CGPoint toPoint;
    toPoint.x = point.x - offset.x;
    toPoint.y = point.y - offset.y;

    [(CAScrollLayer *)self.layer scrollToPoint:toPoint];
    
    [recognizer setTranslation:CGPointZero inView:self];
    
    switch (_minCalendarUnit) {
        case NSCalendarUnitSecond:
            _baseTimeInterval -= offset.x/SCALE_SPACE;
            break;
        case NSCalendarUnitMinute:
            _baseTimeInterval -= offset.x/SCALE_SPACE * 60;
            break;
        case NSCalendarUnitHour:
            _baseTimeInterval -= offset.x/SCALE_SPACE * 60 * 60;
            break;
        case NSCalendarUnitDay:
            _baseTimeInterval -= offset.x/SCALE_SPACE * 60 * 60 * 24;
            break;
        default:
            break;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if([self.delegate respondsToSelector:@selector(timeEventView:didUpdateTimeInterval:)])
        {
            [self.delegate timeEventView:self didUpdateTimeInterval:_baseTimeInterval];
        }
    }

    [self setNeedsDisplay];
}

- (void)doubleTap:(UIPanGestureRecognizer *)recognizer
{
    switch (_minCalendarUnit) {
        case NSCalendarUnitSecond:
            _minCalendarUnit = NSCalendarUnitMinute;
            break;
        case NSCalendarUnitMinute:
            _minCalendarUnit = NSCalendarUnitHour;
            break;
        case NSCalendarUnitHour:
            _minCalendarUnit = NSCalendarUnitDay;
            break;
        case NSCalendarUnitDay:
            _minCalendarUnit = NSCalendarUnitSecond;
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    switch (_minCalendarUnit)
    {
        case NSCalendarUnitSecond:{
            unitFlags  = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
            timeFactor = 1;
            format = @"yyyy-MM-dd HH时mm分ss秒";

            secondScaleTop = 0.45;
            fiveSecondScaleTop = 0.40;
            thirtySecondScaleTop = 0.35;
            minuteScaleTop = 0.30;
            fiveMinuteScaleTop = 0.30;
            thirtyMinuteScaleTop = 0.30;
            hourScaleTop = 0.20;
            twelveHourScaleTop = 0.18;
            dayScaleTop = 0.15;
            firstDayScaleTop = 0.15;
            monthScaleTo = 0.12;
            yearScaleTop = 0.1;
        }
            break;
        case NSCalendarUnitMinute:{
            unitFlags  = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
            timeFactor = 60;
            format = @"yyyy-MM-dd HH时mm分";

            minuteScaleTop = 0.45;
            fiveMinuteScaleTop = 0.40;
            thirtyMinuteScaleTop = 0.35;
            hourScaleTop = 0.30;
            twelveHourScaleTop = 0.26;
            dayScaleTop = 0.20;
            firstDayScaleTop = 0.20;
            monthScaleTo = 0.15;
            yearScaleTop = 0.10;
        }
            break;
        case NSCalendarUnitHour:
        {
            unitFlags  = NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
            timeFactor = 60 * 60;
            format = @"yyyy-MM-dd HH时";

            hourScaleTop = 0.45;
            twelveHourScaleTop = 0.35;
            dayScaleTop = 0.25;
            firstDayScaleTop = 0.25;
            monthScaleTo = 0.20;
            yearScaleTop = 0.15;
        }
            break;
        case NSCalendarUnitDay:
        {
            unitFlags  = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
            timeFactor = 60 * 60 * 24;
            format = @"yyyy-MM-dd";
            
            dayScaleTop = 0.40;
            firstDayScaleTop = 0.30;
            monthScaleTo = 0.20;
            yearScaleTop = 0.10;
        }
            break;
    }
    
    [self drawRect:rect unitFlags:unitFlags timefactor:timeFactor];
    //指示器
    [self drawIndicatorLineRect:rect];
    //顶部时间
    CGRect dateRect = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height * LABEL_HEIGHT);
    [self drawTextRect:dateRect format:format timeInterval:_baseTimeInterval];
    
    QGLogDebug(@"scrollLayer drawRect == %f,%f",self.layer.visibleRect.origin.x,self.layer.visibleRect.origin.y);
}

- (void)drawTextRect:(CGRect)rect format:(NSString *)format timeInterval:(NSTimeInterval)timeInterval
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = format;
    NSString * dateText = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    CGRect dateRect = rect;
    [self addText:dateText rect:dateRect];
}

- (void)drawRect:(CGRect)rect unitFlags:(NSCalendarUnit)unitFlags timefactor:(NSInteger)factor
{
    CGPoint startPoint = rect.origin;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;

    NSTimeInterval startTimeInterval = _baseTimeInterval - width/2/SCALE_SPACE * factor;
    NSTimeInterval endTimeInterval = _baseTimeInterval + width/2/SCALE_SPACE * factor;
    
    NSString * format = @"ss秒";
    CGRect textRect;
    for (NSTimeInterval timeInterval = startTimeInterval; timeInterval < endTimeInterval; timeInterval+=factor) {
        NSDateComponents * dateComponents = [_calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        CGFloat relativeX = (timeInterval - startTimeInterval)/factor*SCALE_SPACE;
        CGFloat startOffsetX = startPoint.x + relativeX;
        CGFloat top = fiveSecondScaleTop;
        
        if (dateComponents.second != 0 && dateComponents.second != NSIntegerMax) {
            BOOL needText = NO;
            if (dateComponents.second%30 == 0) {
                top = thirtySecondScaleTop;
                needText = YES;
            }else if (dateComponents.second%5 == 0) {
                top = fiveSecondScaleTop;
                needText = NO;
            }else{
                top = secondScaleTop;
                needText = NO;
            }
                [self addLine:startOffsetX top:top];
            if (needText) {
                format = @"ss秒";
                textRect = CGRectMake(startOffsetX, height * top -6, 24, 7);
                [self drawTextRect:textRect format:format timeInterval:timeInterval];
            }
        }else
        if (dateComponents.minute != 0 && dateComponents.minute != NSIntegerMax) {
            BOOL needText = NO;
            if (dateComponents.minute%30 == 0) {
                top = thirtyMinuteScaleTop;
                needText = YES;
            }else if (dateComponents.minute%5 == 0) {
                top = fiveMinuteScaleTop;
                needText = _minCalendarUnit == NSCalendarUnitSecond ? YES : NO;
            }else{
                top = minuteScaleTop;
                needText = _minCalendarUnit == NSCalendarUnitSecond ? YES : NO;
            }
            [self addLine:startOffsetX top:top];
            if (needText) {
                format = @"mm分";
                textRect = CGRectMake(startOffsetX, height * top -6, 24, 8);
                [self drawTextRect:textRect format:format timeInterval:timeInterval];
            }
        }else
        if (dateComponents.hour != 0 && dateComponents.hour != NSIntegerMax) {
            BOOL needText = NO;
            if (dateComponents.hour%12 == 0) {
                top = twelveHourScaleTop;
                needText = YES;
            }else
            {
                top = hourScaleTop;
                needText = (_minCalendarUnit != NSCalendarUnitHour && _minCalendarUnit != NSCalendarUnitDay) ? YES : NO;
            }
            [self addLine:startOffsetX top:top];
            if (needText) {
                format = @"HH时";
                textRect = CGRectMake(startOffsetX, height * top -8, 24, 8);
                [self drawTextRect:textRect format:format timeInterval:timeInterval];
            }
        }else
        if (dateComponents.day != 1) {
            BOOL needText = NO;
            if (dateComponents.day == 15) {
                top = firstDayScaleTop;
                needText = YES;
            }else
            {
                top = dayScaleTop;
                needText = _minCalendarUnit != NSCalendarUnitDay ? YES : NO;
            }
            [self addLine:startOffsetX top:top];
            if (needText) {
                format = @"dd日";
                textRect = CGRectMake(startOffsetX, height * top, 40, 9);
                [self drawTextRect:textRect format:format timeInterval:timeInterval];
            }
        }else
        if (dateComponents.month != 1) {
            [self addLine:startOffsetX top:monthScaleTo];
            format = @"MM月";
            CGRect textRect = CGRectMake(startOffsetX, height * monthScaleTo, 40, 10);
            [self drawTextRect:textRect format:format timeInterval:timeInterval];
            continue;
        }else
        {
            [self addLine:startOffsetX top:yearScaleTop];
            format = @"yyyy年";
            CGRect textRect = CGRectMake(startOffsetX, height * yearScaleTop, 40, 11);
            [self drawTextRect:textRect format:format timeInterval:timeInterval];
        }
        //range
        NSDate * date = [_calendar dateFromComponents:dateComponents];
        BOOL locationInRanges = [self locationInRanges:date.timeIntervalSince1970];
        if (locationInRanges == YES) {
            [self addRectangle:startOffsetX rect:rect];
        }
    }
}

- (void)addLine:(CGFloat)x top:(CGFloat)top
{
    CGFloat height = self.bounds.size.height;
    CGPoint point = CGPointMake(x, height * top);
    CGPoint toPoint = CGPointMake(x, height * SCALE_HEIGHT);
    [self addLine:point toPont:toPoint];
}

- (void)addLine:(CGPoint)point toPont:(CGPoint)toPoint
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    [path addLineToPoint:toPoint];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, 1);
    [[UIColor colorWithRGB:@"#858585"] setStroke];
    CGContextStrokePath(ctx);
}

- (void)addText:(NSString *)text rect:(CGRect)rect
{
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.alignment = NSTextAlignmentLeft;
    textStyle.lineSpacing = 5;
    textStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    [textAttributes setValue:[UIFont systemFontOfSize:rect.size.height] forKey:NSFontAttributeName];
    [textAttributes setValue:[UIColor colorWithRGB:@"#858585"] forKey:NSForegroundColorAttributeName];
    [text drawInRect:rect withAttributes:textAttributes];
}

- (void)addRectangle:(CGFloat)x rect:(CGRect)rect
{
    CGFloat height = rect.size.height;
    [[UIColor colorWithRGB:@"#527FFF" alpha:0.25] set];
    CGRect rangeRect = CGRectMake(x, height*SCALE_HEIGHT, SCALE_SPACE, height*(1 - SCALE_HEIGHT));
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:rangeRect];
    path.lineWidth = 0.f;
    [path fill];
    [path stroke];
}

- (void)drawIndicatorLineRect:(CGRect)rect
{
    [[UIColor redColor] set];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat offsetX = rect.origin.x + width/2 + SCALE_SPACE/2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(offsetX, height)];
    [path addLineToPoint:CGPointMake(offsetX, height*SCALE_HEIGHT)];
    [path addLineToPoint:CGPointMake(offsetX - INDICATOR_HEIGHT/2, height*SCALE_HEIGHT - INDICATOR_HEIGHT)];
    [path addLineToPoint:CGPointMake(offsetX + INDICATOR_HEIGHT/2, height*SCALE_HEIGHT - INDICATOR_HEIGHT)];
    [path addLineToPoint:CGPointMake(offsetX, height*SCALE_HEIGHT)];
    [path closePath];
    [path stroke];
    [path fill];
}


- (void)setTimeEvents:(NSArray *)eventInfos;
{
    [_secondRanges removeAllObjects];
    [_mintuteRanges removeAllObjects];
    [_hourRanges removeAllObjects];
    [_dayRanges removeAllObjects];

    for (NLEventInfo *event in eventInfos) {
        NSRange range;
        range.location = event.startTime;
        range.length = event.duration;
        
        NSCalendarUnit unitFlags = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
        NSDateComponents * dateComponents = [_calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970:event.startTime]];

        NSRange secondRange = [self rangeWithRange:range minCalendarUnit:NSCalendarUnitSecond dateComponents:dateComponents];
        [_secondRanges addObject: [NSValue valueWithRange:secondRange]];
        NSRange minuteRange = [self rangeWithRange:range minCalendarUnit:NSCalendarUnitMinute dateComponents:dateComponents];
        [_mintuteRanges addObject: [NSValue valueWithRange:minuteRange]];
        NSRange hourRange = [self rangeWithRange:range minCalendarUnit:NSCalendarUnitHour dateComponents:dateComponents];
        [_hourRanges addObject: [NSValue valueWithRange:hourRange]];
        NSRange dayRange = [self rangeWithRange:range minCalendarUnit:NSCalendarUnitDay dateComponents:dateComponents];
        [_dayRanges addObject: [NSValue valueWithRange:dayRange]];
    }
    [self setNeedsDisplay];
}

- (NSRange)rangeWithRange:(NSRange)range minCalendarUnit:(NSCalendarUnit)unitFlag dateComponents:(NSDateComponents *)dateComponents
{
    NSRange newRange;
    NSInteger factor = 1;
    NSInteger value = 0;
    switch (unitFlag) {
        case NSCalendarUnitSecond:
            return range;
        case NSCalendarUnitMinute:
        {
            value = dateComponents.second;
            factor = 60;
        }
            break;
        case NSCalendarUnitHour:
        {
            value = dateComponents.minute * 60 + dateComponents.second;
            factor = 60 * 60;
        }
            break;
        case NSCalendarUnitDay:
        {
            value = dateComponents.hour * 60 * 60 + dateComponents.minute * 60 + dateComponents.second ;
            factor = 60 * 60 * 24;
        }
            break;
            
        default:
            break;
    }
    
    newRange.location = range.location - value;
    newRange.length = range.length / factor;
    if (((NSInteger)range.length % factor) > 0) {
        newRange.length += 1;
    }
    return newRange;
}

- (BOOL)locationInRanges:(CGFloat)location
{
    switch (_minCalendarUnit) {
        case NSCalendarUnitSecond:
            for (NSValue * rangeValue in _secondRanges) {
                NSRange range = [rangeValue rangeValue];
                BOOL locationinRange = NSLocationInRange(location, range);
                if (locationinRange == YES) {
                    return locationinRange;
                }
            }
            break;
        case NSCalendarUnitMinute:
            for (NSValue * rangeValue in _mintuteRanges) {
                NSRange range = [rangeValue rangeValue];
                BOOL locationinRange = NSLocationInRange(location, range);
                if (locationinRange == YES) {
                    return locationinRange;
                }
            }
            break;
        case NSCalendarUnitHour:
            for (NSValue * rangeValue in _hourRanges) {
                NSRange range = [rangeValue rangeValue];
                BOOL locationinRange = NSLocationInRange(location, range);
                if (locationinRange == YES) {
                    return locationinRange;
                }
            }
            break;
        case NSCalendarUnitDay:
            for (NSValue * rangeValue in _dayRanges) {
                NSRange range = [rangeValue rangeValue];
                BOOL locationinRange = NSLocationInRange(location, range);
                if (locationinRange == YES) {
                    return locationinRange;
                }
            }
            break;
        default:
            break;
    }
    return NO;
}

- (void)orientationChange:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

@end
