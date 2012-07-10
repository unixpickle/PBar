//
//  ANProgressBar.m
//  PBar
//
//  Created by Alex Nichol on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANProgressBar.h"

@interface ANProgressBar (Private)

- (void)drawBackground:(CGContextRef)context;
- (void)drawRepeatingIndeterminate:(CGContextRef)context;

- (void)drawRepeatingValue:(CGContextRef)context;
- (void)drawRepeatingValueTerminatorAtX:(CGFloat)x context:(CGContextRef)context;
- (void)drawGlaze:(CGContextRef)context;
- (CGFloat)progressWidth;

- (void)animationMethod:(id)info;

@end

@implementation ANProgressBar

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Drawing -

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // border color: 0.61046
    // top gradient: 0.73072
    // bottom shadow (3px): 0.81569
    // end color: 0.85882
    
    CGRect borderRect = CGRectMake(1.5, 1.5, self.frame.size.width - 3, self.frame.size.height - 3);
    UIBezierPath * border = [UIBezierPath bezierPathWithRoundedRect:borderRect
                                                  byRoundingCorners:UIRectCornerAllCorners
                                                        cornerRadii:CGSizeMake(2, 2)];
    CGPathRef path = [border CGPath];
    
    borderRect.origin.y += 1;
    UIBezierPath * lightBorder = [UIBezierPath bezierPathWithRoundedRect:borderRect
                                                  byRoundingCorners:UIRectCornerAllCorners
                                                        cornerRadii:CGSizeMake(2, 2)];
    CGPathRef lightPath = [lightBorder CGPath];
    CGContextSetLineWidth(context, 1);
    CGContextSetGrayStrokeColor(context, 0.94118, 1);
    CGContextBeginPath(context);
    CGContextAddPath(context, lightPath);
    CGContextStrokePath(context);
    
    // draw various progress components
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    if (state == ANProgressBarStateValue) {
        [self drawBackground:context];
        [self drawRepeatingValue:context];
    } else {
        [self drawRepeatingIndeterminate:context];
    }
    
    CGContextRestoreGState(context);
    
    // draw border
    CGContextSetLineWidth(context, 1);
    CGContextSetGrayStrokeColor(context, 0.61046, 1);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

#pragma mark - Private -

- (void)drawBackground:(CGContextRef)context {
    CGFloat colors[6] = {0.73072, 1, 0.81569, 1, 0.85822, 1};
    CGFloat locations[3] = {0, 0.16667, 1};
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(gray, colors, locations, 3);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 2), CGPointMake(0, self.frame.size.height - 2), 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(gray);
}

- (void)drawRepeatingIndeterminate:(CGContextRef)context {
    // blue color: 0.26667, 0.59431, 0.9541
    // white color: 0.91765, 0.91765, 0.91765
    CGFloat startX = 0;
    if (animationOffset > 16) {
        startX = -(2 * kANProgressBarSlopeSize) + animationOffset;
    } else {
        startX = -kANProgressBarSlopeSize + animationOffset;
    }
    CGFloat endX = self.frame.size.width;
    
    CGFloat locations[4] = {0, 0.51, 0.51, 1};
    CGFloat blueColors[16] = {0.73333, 0.85882, 0.96471, 1,
        0.40784, 0.65098, 0.94510, 1,
        0.26667, 0.58431, 0.94510, 1,
        0.63529, 0.84314, 0.95294, 1};
    CGFloat whiteColors[8] = {1, 1,
        0.95688, 1,
        0.92157, 1,
        0.93333, 1};
    CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef blueGradient = CGGradientCreateWithColorComponents(rgbSpace, blueColors, locations, 4);
    CGGradientRef whiteGradient = CGGradientCreateWithColorComponents(graySpace, whiteColors, locations, 4);
    
    // draw alternating bar colors
    int color = 0; // 1 = blue, 0 = white
    for (CGFloat x = startX; x <= endX; x += 16, color ^= 1) {
        CGContextSaveGState(context);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, x, 2);
        CGContextAddLineToPoint(context, x + 16, 18);
        CGContextAddLineToPoint(context, x + 32, 18);
        CGContextAddLineToPoint(context, x + 16, 2);
        CGContextClosePath(context);
        
        CGContextClip(context);
        CGGradientRef selGradient = color ? blueGradient : whiteGradient;
        CGContextDrawLinearGradient(context, selGradient, CGPointMake(0, 2), CGPointMake(0, 18), 0);
        
        CGContextRestoreGState(context);
    }
    
    CGGradientRelease(blueGradient);
    CGGradientRelease(whiteGradient);
    CGColorSpaceRelease(rgbSpace);
    CGColorSpaceRelease(graySpace);
}

#pragma mark Values

- (void)drawRepeatingValue:(CGContextRef)context {
    CGFloat width = [self progressWidth];
    if (width >= self.frame.size.width - 5) {
        width = self.frame.size.width;
    } else {
        [self drawRepeatingValueTerminatorAtX:(width + 2) context:context];
        CGContextClipToRect(context, CGRectMake(1, 2, width, self.frame.size.height - 4));
    }
    CGContextSetRGBFillColor(context, 68.0/255.0, 149.0/255.0, 241.0/255.0, 1);
    CGContextFillRect(context, self.bounds);
    
    // draw black blotches
    if (doubleValue < 1) {
        CGContextSetShadow(context, CGSizeMake(0, 0), 5);
        CGContextSetRGBFillColor(context, 0, 0, 0, 1);
        for (CGFloat x = -animationOffset; x <= width + 16; x += 32) {
            CGFloat alpha = 0.05;
            CGPoint center = CGPointMake(x, self.frame.size.height / 2);
            CGFloat rate = 1;
            for (CGFloat r = 12; r > 2; r -= rate) {
                rate += 0.4;
                CGFloat upR = r;
                CGRect ellipseFrame = CGRectMake(center.x - r, center.y - upR, r * 2, upR * 2);
                CGContextSetRGBFillColor(context, 68.0/255.0, 151.0/255.0, 241.0/255.0, alpha / 1.2);
                CGContextFillEllipseInRect(context, ellipseFrame);
            }
        }
    }
    
    [self drawGlaze:context];
}

- (void)drawRepeatingValueTerminatorAtX:(CGFloat)x context:(CGContextRef)context {
    CGFloat colors[4] = {0.47059, 1, 0.7451, 1};
    CGFloat locations[2] = {0, 1};
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(gray, colors, locations, 2);
    CGContextSaveGState(context);
    CGContextClipToRect(context, CGRectMake(x - 1, 2, 1, self.frame.size.height - 4));
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 2), CGPointMake(0, self.frame.size.height - 2), 0);
    CGContextRestoreGState(context);
}

- (void)drawGlaze:(CGContextRef)context {
    // top opacity: 0.3
    // mid opacity: 0.4
    // mid-next opacity: 0
    // bottom opacity: 0.25
    CGFloat colors[8] = {1, 0.65, 1, 0.15, 1, 0, 1, 0.3};
    CGFloat locations[4] = {0, 0.51, 0.51, 1};
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(gray, colors, locations, 4);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 2), CGPointMake(0, self.frame.size.height - 2), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(gray);
}

- (CGFloat)progressWidth {
    return (self.frame.size.width - 4) * doubleValue;
}

#pragma mark - Properties -

- (ANProgressBarState)state {
    return state;
}

- (void)setState:(ANProgressBarState)val {
    state = val;
    [self setNeedsDisplay];
}

- (double)doubleValue {
    return doubleValue;
}

- (void)setDoubleValue:(double)value {
    doubleValue = value;
    [self setNeedsDisplay];
}

#pragma mark - Animation -

- (void)startAnimation:(id)sender {
    if (animationLink) return;
    animationDate = nil;
    animationLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationMethod:)];
    [animationLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation:(id)sender {
    if (!animationLink) return;
    [animationLink invalidate];
    animationLink = nil;
    animationDate = nil;
}

#pragma mark Private

- (void)animationMethod:(id)sender {
    NSDate * date = [NSDate date];
    NSTimeInterval time = (animationDate ? [date timeIntervalSinceDate:animationDate] : 0);
    animationDate = date;
    animationOffset += time * 32;
    while (animationOffset > 32) animationOffset = animationOffset - 32;
    [self setNeedsDisplay];
}

@end
