//
//  ANProgressBar.h
//  PBar
//
//  Created by Alex Nichol on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kANProgressBarHeight 20
#define kANProgressBarSlopeSize 32

typedef enum {
    ANProgressBarStateIndeterminate = 0,
    ANProgressBarStateValue = 1
} ANProgressBarState;

@interface ANProgressBar : UIView {
    ANProgressBarState state;
    double doubleValue;
    
    CADisplayLink * animationLink;
    NSDate * animationDate;
    float animationOffset;
}

@property (readwrite) ANProgressBarState state;
@property (readwrite) double doubleValue;

- (void)startAnimation:(id)sender;
- (void)stopAnimation:(id)sender;

@end
