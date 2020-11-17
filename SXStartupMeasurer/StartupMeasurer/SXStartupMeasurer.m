//
//  SXStartupMeasurer.m
//  SXStartupMeasurer
//
//  Created by Sunny on 2020/11/17.
//

#import "SXStartupMeasurer.h"
#include <stdint.h>
#include <mach/mach_time.h>
#import <UIKit/UIKit.h>


static uint64_t loadTime;
static uint64_t applicationRespondedTime = -1;
static mach_timebase_info_data_t timebaseInfo;

static inline NSTimeInterval MachTimeToSeconds(uint64_t machTime) {
    return ((machTime / 1e9) * timebaseInfo.numer) / timebaseInfo.denom;
}

@implementation SXStartupMeasurer


+ (void)load {
    loadTime = mach_absolute_time();
    mach_timebase_info(&timebaseInfo);
    
    @autoreleasepool {
        __block id obs;
        obs = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                                object:nil queue:nil
                                                            usingBlock:^(NSNotification *note) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    applicationRespondedTime = mach_absolute_time();
                                                                    NSLog(@"app启动用时 %f seconds.", MachTimeToSeconds(applicationRespondedTime - loadTime));
                                                                });
                                                                [[NSNotificationCenter defaultCenter] removeObserver:obs];
                                                            }];
    }
}




@end
