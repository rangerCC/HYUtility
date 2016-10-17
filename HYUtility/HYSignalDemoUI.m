//
//  HYSignalDemoUI.m
//  HYUtility
//
//  Created by 恒阳 on 16/10/17.
//  Copyright © 2016年 恒阳. All rights reserved.
//

#import "HYSignalDemoUI.h"

@interface HYSignalDemoUI ()
@property (nonatomic,strong)UIControl *control;
@end

@implementation HYSignalDemoUI
IMP_SIGNAL(SomeSignal)

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubview:self.control];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.control.frame = self.bounds;
    
}

- (UIControl *)control
{
    if (!_control) {
        UIControl *control = [[UIControl alloc] init];
        [control addTarget:self action:@selector(onControlClicked:) forControlEvents:UIControlEventTouchUpInside];
        control.backgroundColor = [UIColor redColor];
        _control = control;
        
    }
    return _control;
}

- (void)onControlClicked:(id)sender
{
//    [self sendUISignal:self.SomeSignal withObject:nil];
    [self sendUIAction:NSStringFromClass([self class]) ActionName:@"doSomething" Params:@{}];
}

- (void)doSomething
{
    NSLog(@"do something");
}
@end
