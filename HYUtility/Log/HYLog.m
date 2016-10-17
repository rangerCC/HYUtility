//
//  HYLog.m
//  HYUtility
//
//  Created by 恒阳 on 16/10/17.
//  Copyright © 2016年 恒阳. All rights reserved.
//

#import "HYLog.h"

@implementation HYLog
+(instancetype)sharedInstance
{
    static HYLog *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYLog alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

@end
