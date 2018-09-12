//
//  ViewController.m
//  LeeJTomMultiThreading
//
//  Created by JTom on 2018/3/13.
//  Copyright © 2018年 LeeJTom. All rights reserved.
//

#import "ViewController.h"
#import "JTOperation.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//	[self createNSThread2];
//	[self syncConcurrent];
//	[self asyncConcurrent];
//	[self syncSerial];
//	[self asyncSerial];
//	[self syncMain];
	// 使用 NSThread 的 detachNewThreadSelector 方法会创建线程，并自动启动线程执行selector 任务
//	[NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];
	
//	[self asyncMain];
//	[self communication];
//	[self createNSOperation];
//	[self testNSBlockOperationExecution];
//	[self testJTOperation];
//	[self testNSOperationQueue];
//	[self testMaxConcurrentOperationCount];
//	[self testAddDependency];
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"OpenTouchID"] boolValue]) {
//		[self touchID];
//	}else{
//		[self openTouchID];
//	}

//	[self testNSTimer];
}

- (void)testNSTimer {
	//第一类
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];
	//第二类
	NSTimer *timer1 = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];
	NSTimer *timer2 = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

- (void)timerMethod:(NSTimer *)timer {
	NSLog(@"%@ #%@", timer, [NSThread currentThread]);
	[timer invalidate];
	NSLog(@"%@", timer);
	timer = nil;
}

- (void)touchID {
	LAContext *context = [[LAContext alloc]init];
	[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"正在盗取您的个人信息！" reply:^(BOOL success, NSError * _Nullable error) {
		if (success) {
			NSLog(@"success..");
		}else{
			NSLog(@"%@",error);
		}
	}];
}

- (void)openTouchID {
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否开启TouchID?" preferredStyle:UIAlertControllerStyleAlert];
		//同意开启TouchID
		[alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"OpenTouchID"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"OpenTouchIDSuccess" object:nil];
		}]];
		//不同意开启TouchID
		[alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
			[[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"OpenTouchID"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"OpenTouchIDSuccess" object:nil];
		}]];
		
		[self presentViewController:alertController animated:YES completion:nil];
	});
}

- (void)testAddDependency {
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	
	NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
		for (int i = 0; i < 3; i++) {
			NSLog(@"operation1: %@",[NSThread currentThread]);
		}
	}];
	
	NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
		for (int i = 0; i < 3; i++) {
			NSLog(@"operation2: %@",[NSThread currentThread]);
		}
	}];
	
	[operation2 addDependency:operation1];
	
	[queue addOperation:operation1];
	[queue addOperation:operation2];
}

- (void)testMaxConcurrentOperationCount {
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	
	queue.maxConcurrentOperationCount = 1;
//	queue.maxConcurrentOperationCount = 2;
	
	[queue addOperationWithBlock:^{
		for (int i = 0; i < 3; i++) {
			NSLog(@"task1: %@",[NSThread currentThread]);
		}
	}];
	
	[queue addOperationWithBlock:^{
		for (int i = 0; i < 3; i++) {
			NSLog(@"task2: %@",[NSThread currentThread]);
		}
	}];
	
	[queue addOperationWithBlock:^{
		for (int i = 0; i < 3; i++) {
			NSLog(@"task3: %@",[NSThread currentThread]);
		}
	}];
}

- (void)testNSOperationQueue {
	//创建队列，默认并发
	NSOperationQueue *queuq = [[NSOperationQueue alloc] init];
	//创建NSInvocationOperation
	NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationAddOperation) object:nil];
	//创建NSBlockOperation
	NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
		for (int i = 0; i < 3; i++) {
			NSLog(@"NSBlockOperation: %@", [NSThread currentThread]);
		}
	}];
	//addOperation
	[queuq addOperation:invocationOperation];
	[queuq addOperation:blockOperation];
}

- (void)operationAddOperation {
	NSLog(@"NSInvocationOperation: %@", [NSThread currentThread]);
}
//
//- (void)testNSOperationQueue {
//	//主队列，主队列上的任务是在主线程执行的。
//	NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//	//其他队列（非主队列），加入到'非队列'中的任务默认就是并发，开启多线程。
//	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//
//}
- (void)testJTOperation {
	JTOperation *operation = [[JTOperation alloc]init];
	[operation start];
}

- (void) createNSOperation {
	NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperation) object:nil];
	
	[invocationOperation start];
}

- (void) invocationOperation {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
}

- (void) testNSBlockOperationExecution {
	NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
		NSLog(@"main task = >currentThread: %@", [NSThread currentThread]);
	}];
	
	[blockOperation addExecutionBlock:^{
		NSLog(@"task1 = >currentThread: %@", [NSThread currentThread]);
	}];
	
	[blockOperation addExecutionBlock:^{
		NSLog(@"task2 = >currentThread: %@", [NSThread currentThread]);
	}];
	
	[blockOperation addExecutionBlock:^{
		NSLog(@"task3 = >currentThread: %@", [NSThread currentThread]);
	}];
	[blockOperation start];
}

- (void)createGCD{
	/*
	* @param label
	* A string label to attach to the queue.
	* This parameter is optional and may be NULL.
	*
	* @param attr
	* A predefined attribute such as DISPATCH_QUEUE_SERIAL,
	* DISPATCH_QUEUE_CONCURRENT, or the result of a call to
	* a dispatch_queue_attr_make_with_* function.
	*
	* @result
	* The newly created dispatch queue.
	*/
	// 串行队列
	dispatch_queue_t serialQueue = dispatch_queue_create("leejtom.testQueue", DISPATCH_QUEUE_SERIAL);
	// 并发队列
	dispatch_queue_t concurrentQueue = dispatch_queue_create("leejtom.testQueue", DISPATCH_QUEUE_CONCURRENT);
//	主队列的获取方法
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
//	全局并发队列的获取方法
	dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	// 同步执行任务
	dispatch_sync(dispatch_get_global_queue(0, 0), ^{
		//TO DO
	});
	// 异步执行任务
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		//TO DO
	});
}
/**
 * 同步执行 + 并发队列
 * 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void) syncConcurrent {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"syncConcurrent begin");
	
	dispatch_queue_t concurrentQueue = dispatch_queue_create("leejtom.testQueue", DISPATCH_QUEUE_CONCURRENT);
	
	dispatch_sync(concurrentQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];// 模拟耗时操作
			NSLog(@"task1--%@", [NSThread currentThread]);// 打印当前线程
		}
	});
	
	dispatch_sync(concurrentQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task2--%@", [NSThread currentThread]);
		}
	});
	
	dispatch_sync(concurrentQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task3--%@", [NSThread currentThread]);
		}
	});
	
	NSLog(@"syncConcurrent end");
}

/**
 *异步执行 + 并发队列
 *特点：可以开启多个线程，任务交替（同时）执行。
 */
- (void) asyncConcurrent {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"asyncConcurrent begin");
	
	dispatch_queue_t concurrentQueue = dispatch_queue_create("leejtom.testQueue", DISPATCH_QUEUE_CONCURRENT);
	
	dispatch_async(concurrentQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];// 模拟耗时操作
			NSLog(@"task1--%@", [NSThread currentThread]);// 打印当前线程
		}
	});
	
	dispatch_async(concurrentQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task2--%@", [NSThread currentThread]);
		}
	});
	
	dispatch_async(concurrentQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task3--%@", [NSThread currentThread]);
		}
	});

	
	NSLog(@"asyncConcurrent end");
}

/**
 * 同步执行 + 串行队列
 * 特点：不会开启新线程，在当前线程执行任务。
 * 任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void) syncSerial {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"syncSerial begin");
	
	dispatch_queue_t serialQueue = dispatch_queue_create("leejtom.testQueue", DISPATCH_QUEUE_SERIAL);
	
	dispatch_sync(serialQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];// 模拟耗时操作
			NSLog(@"task1--%@", [NSThread currentThread]);// 打印当前线程
		}
	});
	
	dispatch_sync(serialQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task2--%@", [NSThread currentThread]);
		}
	});
	
	dispatch_sync(serialQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task3--%@", [NSThread currentThread]);
		}
	});
	
	NSLog(@"syncSerial end");
}

/**
 * 异步执行 + 串行队列
 * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void) asyncSerial {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"asyncSerial begin");
	
	dispatch_queue_t serialQueue = dispatch_queue_create("leejtom.testQueue", DISPATCH_QUEUE_SERIAL);
	
	dispatch_async(serialQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];// 模拟耗时操作
			NSLog(@"task1--%@", [NSThread currentThread]);// 打印当前线程
		}
	});
	
	dispatch_async(serialQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task2--%@", [NSThread currentThread]);
		}
	});
	
	dispatch_async(serialQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task3--%@", [NSThread currentThread]);
		}
	});
	
	NSLog(@"asyncSerial end");
}

/**
 * 同步执行 + 主队列
 * 特点(主线程调用)：互等卡住不执行。
 * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void) syncMain {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"syncMain begin");
	
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	
	dispatch_sync(mainQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];// 模拟耗时操作
			NSLog(@"task1--%@", [NSThread currentThread]);// 打印当前线程
		}
	});
	
	dispatch_sync(mainQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task2--%@", [NSThread currentThread]);
		}
	});
	
	dispatch_sync(mainQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task3--%@", [NSThread currentThread]);
		}
	});
	
	NSLog(@"syncMain end");
}

/**
 * 异步执行 + 主队列
 * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void) asyncMain {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"asyncMain begin");
	
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	
	dispatch_async(mainQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];// 模拟耗时操作
			NSLog(@"task1--%@", [NSThread currentThread]);// 打印当前线程
		}
	});
	
	dispatch_async(mainQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task2--%@", [NSThread currentThread]);
		}
	});
	
	dispatch_async(mainQueue, ^{
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];
			NSLog(@"task3--%@", [NSThread currentThread]);
		}
	});
	
	NSLog(@"asyncMain end");
}

/**
 * 线程间通信
 */
- (void)communication {
	// 获取全局并发队列
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	// 获取主队列
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	
	dispatch_async(queue, ^{
		// 异步追加任务
		for (int i = 0; i < 2; ++i) {
			[NSThread sleepForTimeInterval:2];              // 模拟耗时操作
			NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
		}
		
		// 回到主线程
		dispatch_async(mainQueue, ^{
			[NSThread sleepForTimeInterval:2];
			NSLog(@"2---%@",[NSThread currentThread]);
		});
	});
}

- (void) createNSThread{
	
	NSString *threadName1 = @"NSThread1";
	NSString *threadName2 = @"NSThread2";
	NSString *threadName3 = @"NSThread3";
	NSString *threadNameMain = @"NSThreadMain";
	
	NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething:) object:threadName1];
	[thread1 start];
	
	[NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:threadName2];
	
	[self performSelectorInBackground:@selector(doSomething:) withObject:threadName3];
//	运行在主线程，waitUntilDone：是否阻塞等待@selector(doSomething:)执行完毕
	[self performSelectorOnMainThread:@selector(doSomething:) withObject:threadNameMain waitUntilDone:YES];
	
}

- (void) createNSThread2{
	/** 方法一，需要start */
	NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething1:) object:@"NSThread1"];
	// 线程加入线程池等待CPU调度，时间很快，几乎是立刻执行
	[thread1 start];
	
	/** 方法二，创建好之后自动启动 */
	[NSThread detachNewThreadSelector:@selector(doSomething2:) toTarget:self withObject:@"NSThread2"];
	
	/** 方法三，隐式创建，直接启动 */
	[self performSelectorInBackground:@selector(doSomething3:) withObject:@"NSThread3"];
	
	[self performSelectorOnMainThread:@selector(doSomething4:) withObject:@"NSThread4" waitUntilDone:YES];

}

- (void) doSomething:(NSObject *)object{
		NSLog(@"%@：%@", object,[NSThread currentThread]);
}



- (void)doSomething1:(NSObject *)object {// 传递过来的参数
	NSLog(@"%@",object);
	NSLog(@"doSomething1：%@",[NSThread currentThread]);
}

- (void)doSomething2:(NSObject *)object {
	NSLog(@"%@",object);
	NSLog(@"doSomething2：%@",[NSThread currentThread]);
}

- (void)doSomething3:(NSObject *)object {
	NSLog(@"%@",object);
	NSLog(@"doSomething3：%@",[NSThread currentThread]);
}

- (void)doSomething4:(NSObject *)object {
	NSLog(@"%@",object);
	NSLog(@"doSomething4：%@",[NSThread currentThread]);
}
@end
