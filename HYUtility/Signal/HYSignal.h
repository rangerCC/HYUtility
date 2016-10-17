//
//  HYSignal.h
//  HYUtility
//
//  Created by 恒阳 on 16/10/17.
//  Copyright © 2016年 恒阳. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef	DEF_SIGNAL
#define DEF_SIGNAL( __signal_name ) \
- (NSString *)__signal_name; \
+ (NSString *)__signal_name;

#undef	IMP_SIGNAL
#define IMP_SIGNAL( __signal_name ) \
- (NSString *)__signal_name \
{ \
return (NSString *)[[self class] __signal_name]; \
} \
+ (NSString *)__signal_name \
{ \
static NSString * __local = nil; \
if ( nil == __local ) \
{ \
__local = [NSString stringWithFormat:@"%@.%s", (NSString *)[self class], #__signal_name]; \
} \
return __local; \
}

// 信号量按照Target-Action响应链机制传递，常用
#undef IMP_INTERCEPT
#define IMP_INTERCEPT(signal) \
-(void)interceptUISignal:(HYSignal*)signal

// 响应信号量，由运行时动态实现，可忽略
#undef IMP_RESPONSE
#define IMP_RESPONSE(signal,clz,action) \
-(void)responseUISignal:(TripSignal*)signal className:(NSString*)clz actionName:(NSString*)action

@interface HYSignal : NSObject

@property(nonatomic,assign) BOOL dead;                      //是否标记为无效，YES为无效，则停止回朔
@property(nonatomic,copy) NSString* signalName;             //信号量标记
@property(nonatomic,strong) id object;                      //挟带的对象

@property(nonatomic,copy) NSString* action;                 //要执行的函数原型，(1)function (2)function: (3)function:params:等等

@property(nonatomic,assign) id response;
@property(nonatomic,strong) id params;


@property(nonatomic,copy) NSString* start;                  //源
@property(nonatomic,strong) NSMutableArray* paths;          //传递路径

@end

@interface NSObject (HYSignal)

// 发送信号量，由实现信号量的类处理事件，常用
- (void) sendUISignal:(NSString*)name withObject:(id)object;

// 指定某个类的某个方法处理对应的action事件，可忽略
- (void) sendUIAction:(NSString*)className ActionName:(NSString*)actionName Params:(id)params;
@end
