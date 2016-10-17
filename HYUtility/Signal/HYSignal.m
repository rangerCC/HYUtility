//
//  HYSignal.m
//  HYUtility
//
//  Created by 恒阳 on 16/10/17.
//  Copyright © 2016年 恒阳. All rights reserved.
//

#import "HYSignal.h"
#import <objc/runtime.h>

@implementation HYSignal

-(id)init
{
    self = [super init];
    if(self)
    {
        self.dead = NO;
        self.paths = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

-(NSString*)description
{
    NSLog(@"=== %@.paths === ",self.signalName);
    for(int i=0;i<self.paths.count;i++)
    {
        NSLog(@"⬇ class %@  ",[self.paths objectAtIndex:i]);
    }
    return nil;
}

-(void)dealloc
{
    self.start = nil;
    self.paths = nil;
    self.object = nil;
    self.signalName = nil;
    self.params = nil;
    self.response = nil;
}

@end

@implementation NSObject (HYSignal)

- (void)sendUISignal:(NSString *)name withObject:(id)object
{
    HYSignal *signal = [[HYSignal alloc] init];
    signal.object = object;
    signal.start = NSStringFromClass([self class]);
    signal.signalName = name;
    
    if ([self respondsToSelector:@selector(handleUISignal:)]) {
        [self performSelector:@selector(handleUISignal:) withObject:signal];
    }
}

- (void) sendUIAction:(NSString*)className ActionName:(NSString*)actionName Params:(id)params
{
    HYSignal* signal = [[HYSignal alloc] init];
    signal.signalName = className;
    signal.action = actionName;
    signal.params = params;
    
    if([self respondsToSelector:@selector(handleUISignal:)])
    {
        [self performSelector:@selector(handleUISignal:) withObject:signal];
    }
}

#pragma mark - Kernel Method
-(void) handleUISignal:(HYSignal*)signal
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [signal.paths addObject:NSStringFromClass([self class])];
    
    if(signal.response == nil)
    {
        signal.response = self;
    }
    
    // 指定action实现场景，类名+方法名，可忽略
    if(signal.action)
    {
        if([signal.signalName isEqualToString:NSStringFromClass(self.class)] &&
           [self respondsToSelector:NSSelectorFromString(signal.action)])
        {
            NSUInteger cnt = [signal.action componentsSeparatedByString:@":"].count;
            if(cnt == 1)
            {
                
                [self performSelector:NSSelectorFromString(signal.action)];
                
            }
            else if(cnt == 2)
            {
                
                [self performSelector:NSSelectorFromString(signal.action)
                           withObject:signal.params];
                
            }
            else
            {
                
                [self performSelector:NSSelectorFromString(signal.action) withObjects:signal.params];
                
            }
            
            if(signal.response &&
               [signal.response respondsToSelector:@selector(responseUISignal:className:actionName:)])
            {
                
                [signal.response performSelector:@selector(responseUISignal:className:actionName:)
                                  withParameters:(__bridge void *)(signal),signal.signalName,signal.action,nil];
                
            }
            
            
            
            signal.dead = YES;
            return;
        }
        
    }
    
    // 指定信号处理者处理，通过IMP_INTERCEPT实现对signal的处理
    if([self respondsToSelector:@selector(interceptUISignal:)])
    {
        [self performSelector:@selector(interceptUISignal:) withObject:signal];
    }
    
    if(signal.dead)
    {
        return;
    }
    
    if([self respondsToSelector:@selector(nextResponder)])
    {
        id nextResponder = [self performSelector:@selector(nextResponder)];
        
        if(nextResponder == nil)
        {
            return;
        }
        if([nextResponder respondsToSelector:@selector(handleUISignal:)])
        {
            [nextResponder performSelector:@selector(handleUISignal:) withObject:signal];
        }
    }
    
#pragma clang diagnostic pop
}

#pragma mark - Methods
- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects
{
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    NSUInteger i = 1;
    for (__weak id object in objects)
    {
        [invocation setArgument:&object atIndex:++i];
    }
    [invocation invoke];
    
    if ([signature methodReturnLength])
    {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    
    return nil;
}

- (id)performSelector:(SEL)aSelector withParameters:(void *)firstParameter, ...
{
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSUInteger length = [signature numberOfArguments];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    [invocation setArgument:&firstParameter atIndex:2];
    va_list arg_ptr;
    va_start(arg_ptr, firstParameter);
    for (NSUInteger i = 3; i < length; ++i)
    {
        void *parameter = va_arg(arg_ptr, void *);
        [invocation setArgument:&parameter atIndex:i];
    }
    va_end(arg_ptr);
    
    [invocation invoke];
    
    if ([signature methodReturnLength])
    {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    
    return nil;
}
@end
