//
//  NLTimeEventView.h
//  QH360CameraES
//
//  Created by wanglongxiang on 2018/12/13.
//  Copyright © 2018年 360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLEventInfo : NSObject

@property (nonatomic,assign) NSTimeInterval startTime;
@property (nonatomic,assign) double duration;
@end

@protocol NLTimeEventViewDelegate;

@interface NLTimeEventView : UIView

@property(nonatomic, weak)id<NLTimeEventViewDelegate> delegate;

@property(nonatomic, assign)NSCalendarUnit minCalendarUnit;

- (void)setCurrentTimeInterval:(NSTimeInterval)timeInterval;

- (void)setTimeEvents:(NSArray *)eventInfos;

@end

@protocol NLTimeEventViewDelegate<NSObject>

- (void)timeEventView:(NLTimeEventView *)timeEventView didUpdateTimeInterval:(NSTimeInterval)timeInterval;

@end
