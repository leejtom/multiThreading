//
//  JTOperation.m
//  LeeJTomMultiThreading
//
//  Created by JTom on 2018/3/15.
//  Copyright © 2018年 LeeJTom. All rights reserved.
//

#import "JTOperation.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif
@implementation JTOperation

- (void)main {
	for (int i = 0; i < 3; i++) {
		NSLog(@"NSOperation的子类：%@",[NSThread currentThread]);
	}
}
@end
