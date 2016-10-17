//
//  ViewController.m
//  HYUtility
//
//  Created by 恒阳 on 16/10/17.
//  Copyright © 2016年 恒阳. All rights reserved.
//

#import "ViewController.h"

#import "HYSignalDemoUI.h"

@interface ViewController ()
@property (nonatomic , strong) HYSignalDemoUI *demoUI;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blueColor];
    self.title = @"Utility";
    
    HYSignalDemoUI *demoUI = [[HYSignalDemoUI alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:demoUI];
    self.demoUI = demoUI;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Signal
IMP_INTERCEPT(signal)
{
    if ([signal.signalName isEqualToString:self.demoUI.SomeSignal]) {
        NSMutableString *pathString = [[NSMutableString alloc] init];
        for (NSString *path in signal.paths) {
            [pathString appendString:[NSString stringWithFormat:@" -> %@ ",path]];
        }
        NSLog(@"signal paths are : %@",pathString);
    }
    signal.dead = YES;
}

@end
