//
//  ANAppDelegate.h
//  PBar
//
//  Created by Alex Nichol on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANProgressBar.h"

@interface ANAppDelegate : UIResponder <UIApplicationDelegate> {
    ANProgressBar * progress;
    UISlider * slider;
}

@property (strong, nonatomic) UIWindow * window;

- (void)sliderChanged:(id)sender;

@end
