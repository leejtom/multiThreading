# iOS多线程（Pthread、NSThread、GCD、NSOperation）
iOS多线程（Pthread、NSThread、GCD、NSOperation）
本文纯属个人读书笔记。

本文主要分为以下模块：
>一、知识点<br>二、线程的生命周期：新建 - 就绪 - 运行 - 阻塞 - 死亡<br>三、多线程的四种方案：Pthread、NSThread、GCD、NSOperation<br>四、线程安全问题<br>五、NSThread的使用<br>六、GCD的理解与使用<br>七、NSOperation的理解与使用

## 一、知识点：
- CPU时间片，每个一个获得CPU任务只能运行一个时间片规定的时间。
- 线程就是一段代码以及运行时数据。
- 每个应用程序都是一个进程。
- 一个进程的所有任务都在线程中进行，每个进程都至少有一个线程（主线程）。
- 主线程：处理UI，所有更新UI的操作都必须在主线程上执行。不要把耗时操作放在主线程，会卡界面。
- 多线程：在同一时刻，一个CPU只能处理1条线程，但CPU可以在多条线程之间快速的切换，只要切换的足够快，就造成了多线程一同执行的假象。

#### 我们运用多线程的目的是：将耗时的操作放在后台执行！

## 二、线程的生命周期：新建 - 就绪 - 运行 - 阻塞 - 死亡

	1. 新建：实例化线程对象
	2. 就绪：向线程对象发送start消息，线程对象被加入可调度线程池等待CPU调度
	3. 运行：被CPU执行。在执行完成前，状态可能会在就绪和运行之间来回切换。又CPU负责。
	4. 阻塞：当满足某个预定条件是，可以使用休眠或锁，阻塞线程执行。
	    * sleepForTimeInterval （休眠指定时长），
        * sleepUntiDate（休眠到指定日期），
        * @synchronized(self)：（互斥锁）
    5. 死亡：
        * 正常死亡，线程执行完毕。
        * 非正常死亡，当满足某个条件后，在线程内部终止执行/在主线程终止线程对象。
    6. 线程的exit和cancel：
        * [thread exit]: 一旦强行终止线程，后续的所有代码都不会被执行。
        * [thread cancel]: 默认情况（延迟取消），它就是给pthread设置取消标志,  
        pthread线程在很多时候会查看自己是否有取消请求。
 
## 三、多线程的四种方案：Pthread、NSThread、GCD、NSOperation

    1. Pthread: POSIX线程（POSIX threads），简称Pthreads，是线程的POSIX标准。  
    运用C语言，是一套通用的API，可跨平台Unix/Linux/Windows。线程的生命周期由程序员管理。
    2. NSThread：面向对象，可直接操作线程对象。线程的生命周期由程序员管理。
    3. GCD：代替NSThread，可以充分利用设备的多核，自动管理线程生命周期。
    4. NSOperation：底层是GCD，比GCD多了一些方法，更加面向对象，自动管理线程生命周期。
    
## 四、线程安全问题
    当多个线程访问同一块资源时，很容易引发数据错乱和数据安全问题。

#### 解决多线程安全问题方案：
####  1. 方法一：互斥锁（同步锁）   
>用于保护临界区，确保同一时间只有一个线程访问数据。   
如果代码中只有一个地方需要加锁，大多都使用self作为锁对象，这样可以避免单独再创建一个锁对象。  
加了互斥做的代码，当新线程访问时，如果发现其他线程正在执行锁定的代码，新线程就会进入休眠。

    @synchronized(锁对象){
        //TO DO
    }

####  2. 方法一：自旋锁
  
>与互斥量类似，它不是通过休眠使进程阻塞，而是在获取锁之前一直处于忙等(自旋)阻塞状态。   
用在以下情况：锁持有的时间短，而且线程并不希望在重新调度上花太多的成本。"原地打转"。   
自旋锁与互斥锁的区别：线程在申请自旋锁的时候，线程不会被挂起，而是处于忙等的状态。

>加了自旋锁，当新线程访问代码时，如果发现有其他线程正在锁定代码，新线程会用死循环的方式，一直等待锁定的代码执行完成。相当于不停尝试执行代码，比较消耗性能。
属性修饰atomic本身就有一把自旋锁。


#### 属性修饰atomic和nonatomic
>#### atomic（默认）：原子属性(线程安全)，保证同一时间只有一个线程能够写入(但是同一个时间多个线程都可以取值)，atomic 本身就有一把锁(自旋锁) ,需要消耗大量的资源。
>#### nonatomic：非原子属性(非线程安全),同一时间可以有很多线程读和写,多线程情况下数据可能会有问题！不过效率更高，一般情况下使用nonatomic。

## 五、NSThread的使用
### 1. NSThread创建线程
    - init方式
    - detachNewThreadSelector创建好之后自动启动
    - performSelectorInBackground创建好之后也是直接启动
    
   
 ```
- (void) createNSThread{
	
	NSString *threadName1 = @"NSThread1";
	NSString *threadName2 = @"NSThread2";
	NSString *threadName3 = @"NSThread3";
	NSString *threadNameMain = @"NSThreadMain";
	
	NSThread *thread1 = [[NSThread alloc] initWithTarget:self  
    selector:@selector(doSomething:) object:threadName1];
	[thread1 start];
	
	[NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self   
   withObject:threadName2];
	
	[self performSelectorInBackground:@selector(doSomething:)   
	withObject:threadName3];
	
    //运行在主线程，waitUntilDone：是否阻塞等待@selector(doSomething:)执行完毕
	[self performSelectorOnMainThread:@selector(doSomething:)   
	withObject:threadNameMain waitUntilDone:YES];
	
}

- (void) doSomething:(NSObject *)object{
		NSLog(@"%@：%@", object,[NSThread currentThread]);
}
```

### 2. NSThread的常用类方法
- 返回当前线程
```   
// 当前线程
[NSThread currentThread];
NSLog(@"%@",[NSThread currentThread]);
// 如果number=1，则表示在主线程，否则是子线程
打印结果：<NSThread: 0x608000261380>{number = 1, name = main}。
```
- 阻塞休眠
```
//休眠多久
[NSThread sleepForTimeInterval:2];
//休眠到指定时间
[NSThread sleepUntilDate:[NSDate date]];
```
- 类方法补充
```
//退出线程
[NSThread exit];
//判断当前线程是否为主线程
[NSThread isMainThread];
//判断当前线程是否是多线程
[NSThread isMultiThreaded];
主线程的对象
NSThread *mainThread = [NSThread mainThread];
```
- NSThread的一些属性
```
//线程是否在执行
thread.isExecuting;
//是否被取消
thread.isCancelled;
//是否完成
thread.isFinished;
//是否是主线程
thread.isMainThread;
//线程的优先级，取值范围0.0-1.0,默认优先级0.5，1.0表示最高优先级，优先级高，CPU调度的频率高
thread.threadPriority;
```
## 六、GCD的理解与使用
### No.1：GCD的特点
>- GCD会自动利用更多的CPU内核

>- GCD自动管理线程的生命周期（创建线程、调度任务、销毁线程等）

>- 程序员只需要告诉GCD想要如何执行任务，不需要编写任何线程管理代码

### No.2：GCD的基本概念
#### 2.1. 任务
>__任务__ ：就是执行操作的意思，换句话说就是你在线程中执行的那段代码。在 GCD 中是放在 block 中的。   
执行任务有两种方式：__同步执行（sync）和异步执行（async）__。    
两者的主要区别是：__是否等待队列的任务执行结束，以及是否具备开启新线程的能力__。
- __同步执行（sync）__：
    - 同步同步添加任务到指定的队列中，在添加的任务执行结束之前，会一直等待，直到队列里面的任务完成之后再继续执行
    - 只能在当前线程中执行任务，__不具备开启新线程的能力__。
- __异步执行（async）__：
    - 异步添加任务到指定的队列中，它不会做任何等待，可以继续执行任务。
    - 可以在新的线程中执行任务，__具备开启新线程的能力__。
    - 异步是多线程的代名词。
    >__注意__：异步执行（async）虽然具有开启新线程的能力，但是并不一定开启新线程。这跟任务所指定的 __队列类型__ 有关

#### 2.2. 队列
>__队列（Dispatch Queue）：__ 这里的队列执行任务的等待队列，即用来存放任务的队列。队列是一种特殊的线性表，采用 __FIFO（先进先出）__ 的原则，即 __新任务总是被插入到队列的末尾__，而读取任务的时候总是 __从队列的头部开始读取__ 。每读取一个任务，则从队列中释放一个任务。结构图：

![](https://user-gold-cdn.xitu.io/2018/3/14/1622324a65154665?w=1230&h=458&f=png&s=41922)

在GCD中有两种队列：__串行队列和并发队列__。两者都符合FIFO原则。  
两者的主要 __区别__ 是：__执行顺序不同__，以及 __开启线程数不同__ 。
-  __串行队列（Serial Dispatch Queue）：__
    - 每次只有一个任务被执行，让任务一个接着一个地执行（只开启一个线程）。
![](https://user-gold-cdn.xitu.io/2018/3/14/1622312fedd0496a?w=700&h=284&f=png&s=15527)
-   __并发队列（Concurrent Dispatch Queue）：__
    - 可以让多个任务并发（同时）执行。（可以开启多个线程，并且同时执行任务）。
    
![](https://user-gold-cdn.xitu.io/2018/3/14/16223133327b5fd8?w=700&h=349&f=png&s=16894)
 >__注意__：__并发队列__ 的并发功能只有在异步（dispatch_async）函数下才有效

>__GCD总结__：将任务（要在线程中执行的操作block）添加到队列（自己创建或使用全局并发队列），并且制定执行任务的方式（异步或同步）。

### No.3：GCD 的使用步骤
1. 创建一个队列
2. 将任务追加到任务的等待队列中，然后系统就会根据任务类型执行任务


#### 3.1 队列的创建方法/获取方法
- 可以使用`dispatch_queue_create`来创建队列，需要传入两个参数，第一个参数表示队列的 __唯一标识符，用于DEBUG，可为空__，推荐使用应用程序ID这种逆序全程域名；第二个参数表示 __队列任务类型，串行或并发队列__。
- `DISPATCH_QUEUE_SERIAL` 表示串行队列
- `DISPATCH_QUEUE_CONCURRENT` 表示并发队列

``` 
// 串行队列
dispatch_queue_t serialQueue = dispatch_queue_create("com.leejtom.testQueue",   
DISPATCH_QUEUE_SERIAL);
// 并发队列
dispatch_queue_t concurrentQueue = dispatch_queue_create("com.leejtom.testQueue", 
DISPATCH_QUEUE_CONCURRENT);
```
- 对于 __串行队列__，GCD提供了一种特殊的串行队列：__主队列（Main Dispatch Queue）__。
    - 主队列复制在主线程上调度任务，如果主线程上已经有任务正在执行，主队列会等到主线程空闲后再调度任务。
    - 所有放到主队列中任务，都会放到主线程中执行。
    - 通常是返回主线程 __更新UI__ 的时候使用。
    - 可使用`dispatch_get_main_queue()`获得主队列。
```
//主队列的获取方法
dispatch_queue_t mainQueue = dispatch_get_main_queue();
```

- 对于 __并发队列__，GCD默认提供了 __全局并发队列（Global Dispatch Queue）__。
    - 可以使用`dispatch_get_global_queue`来获取。
        - 第一个参数：表示队列优先级，一般用`DISPATCH_QUEUE_PRIORITY_DEFAULT`
        - 第二个参数：使用0
```
//全局并发队列的获取方法
dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

#define DISPATCH_QUEUE_PRIORITY_HIGH 2
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
```

通常我们这样使用两者：
```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时操作放在这里
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 回到主线程进行UI操作
            
        });
    });
```
#### 3.2 同步/异步/任务、创建方式
- GCD 提供了同步执行任务的创建方法`dispatch_sync`和异步执行任务创建方法`dispatch_async`。
```
// 同步执行任务
dispatch_sync(dispatch_get_global_queue(0, 0), ^{
	//TO DO
});
// 异步执行任务
dispatch_async(dispatch_get_global_queue(0, 0), ^{
	//TO DO
});
```
#### 3.3 GCD的组合方式：
>1. 同步执行 + 并发队列
>2. 异步执行 + 并发队列
>3. 同步执行 + 串行队列
>4. 异步执行 + 串行队列
>5. 同步执行 + 主队列
>6. 异步执行 + 主队列

| 区别 | 并发队列 | 串行队列 | 主队列 |   
| :-: | :-: | :-: | :-: | 
| 同步(sync)| 没有开启新线程，<br>串行执行任务 |没有开启新线程，<br>串行执行任务| 主线程调用：死锁卡住不执行；<br>其他线程调用：没有开启新线程，<br>串行执行任务
| 异步(async) | 有开启新线程，<br>并发执行任务 | 有开启新线程(1条)，<br>串行执行任务 | 没有开启新线程，<br>串行执行任务 |

### No.4. GCD的基本使用
#### 4.1 同步执行 + 并发队列
- 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
```
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

```
输入结果为 __顺序执行，都在主线程:__
> currentThread: <NSThread: 0x115d0ba00>{number = 1, name = main}  
syncConcurrent begin  
task1--<NSThread: 0x115d0ba00>{number = 1, name = main}  
task1--<NSThread: 0x115d0ba00>{number = 1, name = main}  
task2--<NSThread: 0x115d0ba00>{number = 1, name = main}  
task2--<NSThread: 0x115d0ba00>{number = 1, name = main}  
task3--<NSThread: 0x115d0ba00>{number = 1, name = main}  
task3--<NSThread: 0x115d0ba00>{number = 1, name = main}  
syncConcurrent end

#### 4.2 异步执行 + 并发队列
- 特点：可以开启多个线程，任务交替（同时）执行。

```
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
```
输出结果为可以 __开启多个线程，任务交替（同时）执行：__
> currentThread: <NSThread: 0x113e05aa0>{number = 1, name = main}   
asyncConcurrent begin   
asyncConcurrent end  
task3--<NSThread: 0x113d8a720>{number = 3, name = (null)}  
task1--<NSThread: 0x113d89e40>{number = 4, name = (null)}  
task2--<NSThread: 0x113d83c60>{number = 5, name = (null)}  
task3--<NSThread: 0x113d8a720>{number = 3, name = (null)}  
task2--<NSThread: 0x113d83c60>{number = 5, name = (null)}  
task1--<NSThread: 0x113d89e40>{number = 4, name = (null)}   

在 __异步执行 + 并发队列__ 中可以看出：
- 除了当前线程（主线程），系统又开启了3个线程，并且任务是交替/同时执行的。（__异步__ 执行具备开启新线程的能力。且 __并发队列__ 可开启多个线程，同时执行多个任务）。
- 所有任务是在打印的 __asyncConcurrent begin__ 和 __asyncConcurrent end__ 之后才执行的。说明当前线程没有等待，而是直接开启了新线程，在新线程中执行任务（异步执行不做等待，可以继续执行任务）。   


#### 4.3 同步执行 + 串行队列
- 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
```
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

```
输出结果为 __顺序执行，都在主线程:__
>currentThread: <NSThread: 0x11fe04970>{number = 1, name = main}<br>
syncSerial begin<br>
task1--<NSThread: 0x11fe04970>{number = 1, name = main}<br>
task1--<NSThread: 0x11fe04970>{number = 1, name = main}<br>
task2--<NSThread: 0x11fe04970>{number = 1, name = main}<br>
task2--<NSThread: 0x11fe04970>{number = 1, name = main}<br>
task3--<NSThread: 0x11fe04970>{number = 1, name = main}<br>
task3--<NSThread: 0x11fe04970>{number = 1, name = main}<br>
syncSerial end


#### 4.4 异步执行 + 串行队列
- 会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务
```
/**
 * 异步执行 + 串行队列
 * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void) asyncSerial {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
	NSLog(@"asyncSerial begin");
	
	dispatch_queue_t serialQueue = dispatch_queue_create("leejtom.testQueue",DISPATCH_QUEUE_SERIAL);
	
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
```
输出结果为 __顺序执行，有不同线程：__
>currentThread: <NSThread: 0x101005730>{number = 1, name = main}<br>
asyncSerial begin<br>
asyncSerial end<br>
task1--<NSThread: 0x1010ab140>{number = 3, name = (null)}<br>
task1--<NSThread: 0x1010ab140>{number = 3, name = (null)}<br>
task2--<NSThread: 0x1010ab140>{number = 3, name = (null)}<br>
task2--<NSThread: 0x1010ab140>{number = 3, name = (null)}<br>
task3--<NSThread: 0x1010ab140>{number = 3, name = (null)}<br>
task3--<NSThread: 0x1010ab140>{number = 3, name = (null)}<br>

- 开启了一条新线程（ __异步执行__ 具备开启新线程的能力，__串行队列__ 只开启一个线程）。
- 所有任务是在打印的 __asyncSerial begin__ 和 __asyncSerial end__ 之后才开始执行的（异步执行不会做任何等待，可以继续执行任务）。
- 任务是按顺序执行的（ __串行队列__ 每次只有一个任务被执行，任务一个接一个按顺序执行）。

#### 4.5 同步执行 + 主队列
`同步执行 + 主队列`在不同线程中调用结果也是不一样，在主线程中调用会出现死锁，而在其他线程中则不会。

##### 4.5.1 同步执行 + 主队列
- 主队列：GCD自带的一种特殊的串行队列
    - 所有放在主队列中的任务，都会放到主线程中执行
    - 可使用`dispatch_get_main_queue()`获得主队列
- 发生死锁，互等卡住不执行，程序崩溃
```
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
```
输出结果 __发生死锁，互等卡住不执行，程序崩溃__：
>currentThread: <NSThread: 0x101201f70>{number = 1, name = main}
syncMain begin<br>
(lldb)

这是因为我们在主线程中执行`syncMain`方法，相当于把`syncMain`任务放到了主线程的队列中。而`同步执行(dispatch_sync)`会等待当前队列中的任务执行完毕，才会接着执行。那么当我们把任务1追加到主队列中，任务1就在等待主线程处理完`syncMain`任务。而`syncMain`任务需要等待`任务1`执行完毕，才能接着执行。

那么，现在的情况就是`syncMain`任务和`任务1`都在等对方执行完毕。这样大家互相等待，所以就卡住了，所以我们的任务执行不了，而且`syncMain end`也没有打印。

 __要是如果不在主线程中调用，而在其他线程中调用会如何呢？__

#### 4.5.2 在其他线程中调用`同步执行 + 主队列`
- 不会开启新线程，执行完一个任务，再执行下一个任务
```
// 使用 NSThread 的 detachNewThreadSelector 方法会创建线程，并自动启动线程执行selector 任务
[NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];
```
输出结果
>currentThread: <NSThread: 0x121d96740>{number = 3, name = (null)}<br>
syncMain begin<br>
task1--<NSThread: 0x121d0ba20>{number = 1, name = main}<br>
task1--<NSThread: 0x121d0ba20>{number = 1, name = main}<br>
task2--<NSThread: 0x121d0ba20>{number = 1, name = main}<br>
task2--<NSThread: 0x121d0ba20>{number = 1, name = main}<br>
task3--<NSThread: 0x121d0ba20>{number = 1, name = main}<br>
task3--<NSThread: 0x121d0ba20>{number = 1, name = main}<br>
syncMain end<br>

在其他线程中使用`同步执行 + 主队列`可看到：

所有任务都是在主线程（非当前线程）中执行的，没有开启新的线程（所有放在主队列中的任务，都会放到主线程中执行）。
所有任务都在打印的`syncMain begin`和`syncMain end`之间执行（同步任务需要等待队列的任务执行结束）。
任务是按顺序执行的（主队列是串行队列，每次只有一个任务被执行，任务一个接一个按顺序执行）。
为什么现在就不会卡住了呢？
因为`syncMain `任务放到了其他线程里，而任务1、任务2、任务3都在追加到主队列中，这三个任务都会在主线程中执行。`syncMain` 任务在其他线程中执行到追加任务1到主队列中，因为主队列现在没有正在执行的任务，所以，会直接执行主队列的任务1，等任务1执行完毕，再接着执行任务2、任务3。所以这里不会卡住线程。


#### 4.6 异步执行 + 主队列 
- 只在主线程中执行任务，执行完一个任务，再执行下一个任务。
```
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
```
输出结果：
>currentThread: <NSThread: 0x100e05980>{number = 1, name = main}<br>
asyncMain begin<br>
asyncMain end<br>
task1--<NSThread: 0x100e05980>{number = 1, name = main}<br>
task1--<NSThread: 0x100e05980>{number = 1, name = main}<br>
task2--<NSThread: 0x100e05980>{number = 1, name = main}<br>
task2--<NSThread: 0x100e05980>{number = 1, name = main}<br>
task3--<NSThread: 0x100e05980>{number = 1, name = main}<br>
task3--<NSThread: 0x100e05980>{number = 1, name = main}<br>
- 所有任务都是在当前线程（主线程）中执行的，并没有开启新的线程（虽然异步执行具备开启线程的能力，但因为是主队列，所以所有任务都在主线程中）。
- 所有任务是在打印的syncConcurrent---begin和syncConcurrent---end之后才开始执行的（异步执行不会做任何等待，可以继续执行任务）。
任务是按顺序执行的（因为主队列是串行队列，每次只有一个任务被执行，任务一个接一个按顺序执行）。

#### 5. GCD 线程间的通信

在iOS开发过程中，我们一般在主线程里边进行UI刷新，例如：点击、滚动、拖拽等事件。我们通常把一些耗时的操作放在其他线程，比如说图片下载、文件上传等耗时操作。而当我们有时候在其他线程完成了耗时操作时，需要回到主线程，那么就用到了线程之间的通讯。

```
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
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}
```
>1---<NSThread: 0x159e97a40>{number = 3, name = (null)}<br>
1---<NSThread: 0x159e97a40>{number = 3, name = (null)}<br>
2---<NSThread: 0x159e08c20>{number = 1, name = main}<br>

- 可以看到在其他线程中先执行任务，执行完了之后回到主线程执行主线程的相应操作。


## 七、NSOperation的理解与使用
### 1. NSOperation简介
NSOperation是基于GCD之上的更高一层封装，NSOperation需要配合NSOperationQueue来实现多线程。

NSOperatino实现多线程的步骤如下：
>1. 创建任务：先将需要执行的操作封装到`NSOperation`对象中。
>2. 创建队列：创建`NSOperationQueue`。
>3. 将任务加入到队列中：将`NSOperation`对象添加到`NSOperationQueue`中。

需要注意的是，NSOperation是个抽象类，实际运用时中需要使用它的子类，有三种方式：
>1. 使用子类NSInvocationOperation
>2. 使用子类NSBlockOperation
>3. 定义继承自NSOperation的子类，通过实现内部相应的方法来封装任务。

### 2. NSOperation的三种创建方式
> 1. NSInvocationOperation<br>
> 2. NSBlockOperation<br>
> 3. 运用继承自NSOperation的子类

__2.1 NSInvocationOperation的使用__

创建`NSInvocationOperation对象`并关联方法，之后start。
```
- (void) createNSOperation {
	NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperation) object:nil];
	
	[invocationOperation start];
}

- (void) invocationOperation {
	NSLog(@"currentThread: %@", [NSThread currentThread]);
}
```
输出结果 __程序在主线程执行，没有开启新线程：__
>currentThread: <NSThread: 0x143d0b880>{number = 1, name = main}

__2.2 通过`addExecutionBlock`这个方法可以让NSBlockOperation实现多线程。__

```
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
```
结果：NSBlockOperation`创建时block`中的任务是在`主线程`执行，而运用`addExecutionBlock`加入的任务是在`子线程`执行的。

>main task = >currentThread: <NSThread: 0x10160b760>{number = 1, name = main}<br>
task1 = >currentThread: <NSThread: 0x101733690>{number = 3, name = (null)}<br>
task2 = >currentThread: <NSThread: 0x10160b760>{number = 1, name = main}<br>
task3 = >currentThread: <NSThread: 0x101733690>{number = 3, name = (null)}

 __2.3 运用继承自NSOperation的子类__
首先我们定义一个继承自NSOperation的类，然后重写它的main方法。
```
//  JTOperation.m
#import "JTOperation.h"
@implementation JTOperation

- (void)main {
	for (int i = 0; i < 3; i++) {
		NSLog(@"NSOperation的子类：%@",[NSThread currentThread]);
	}
}

//调用
- (void)testJTOperation {
	JTOperation *operation = [[JTOperation alloc]init];
	[operation start];
}
```
运行结果 __在主线程执行:__
>NSOperation的子类：<NSThread: 0x101605ba0>{number = 1, name = main}<br>
NSOperation的子类：<NSThread: 0x101605ba0>{number = 1, name = main}<br>
NSOperation的子类：<NSThread: 0x101605ba0>{number = 1, name = main}<br>

### 3. 队列NSOperationQueue
NSOperationQueue有两种队列：`主队列`、`其他队列`。其他队列包含了 __串行和并发。__

- 主队列，主队列上的任务是在主线程执行的。
```
NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
```
- 其他队列（非主队列），加入到'非队列'中的任务默认就是并发，开启多线程。
```
NSOperationQueue *queue = [[NSOperationQueue alloc]init];
```
__注意：__
>1. 非主队列（其他队列）可以实现串行或并行。<br> 
>2. 队列NSOperationQueue有一个参数叫做最大并发数：
```
@property NSInteger maxConcurrentOperationCount;
```

>3. maxConcurrentOperationCount默认为-1，直接并发执行，所以加入到‘非队列’中的任务默认就是`并发，开启多线程`。

```
static const NSInteger NSOperationQueueDefaultMaxConcurrentOperationCount = -1;
```

>4. 当maxConcurrentOperationCount为1时，则表示不开线程，也就是`串行`。
>5. 当maxConcurrentOperationCount大于1时，进行`并发执行`。
>6. 系统对最大并发数有一个限制，所以即使程序员把maxConcurrentOperationCount设置的很大，系统也会自动调整。所以把最大并发数设置的很大是没有意义的。



### 4. NSOperation + NSOperationQueue
把任务加入队列，这才是NSOperation的常规使用方式。
- addOperation添加任务到队列
```
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
```
运行结果如下，任务确实是在子线程中执行。

>NSInvocationOperation: <NSThread: 0x101a42bf0>{number = 3, name = (null)}<br>
NSBlockOperation: <NSThread: 0x101a42bf0>{number = 3, name = (null)}<br>
NSBlockOperation: <NSThread: 0x101a42bf0>{number = 3, name = (null)}<br>
NSBlockOperation: <NSThread: 0x101a42bf0>{number = 3, name = (null)}<br>

- 运用最大并发数实现串行
运用队列的属性maxConcurrentOperationCount（最大并发数）来实现串行，值需要把它设置为1就可以了，下面我们通过代码验证一下。

```
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
```
运行结果如下，当最大并发数为1的时候，虽然开启了线程，但是任务是顺序执行的，所以实现了串行：

>task1: <NSThread: 0x11be67dc0>{number = 3, name = (null)}<br>
task1: <NSThread: 0x11be67dc0>{number = 3, name = (null)}<br>
task1: <NSThread: 0x11be67dc0>{number = 3, name = (null)}<br>
task2: <NSThread: 0x11bdb1bf0>{number = 4, name = (null)}<br>
task2: <NSThread: 0x11bdb1bf0>{number = 4, name = (null)}<br>
task2: <NSThread: 0x11bdb1bf0>{number = 4, name = (null)}<br>
task3: <NSThread: 0x11be67dc0>{number = 3, name = (null)}<br>
task3: <NSThread: 0x11be67dc0>{number = 3, name = (null)}<br>
task3: <NSThread: 0x11be67dc0>{number = 3, name = (null)}<br>

当最大并发数变为2，会发现任务就变成了并发执行：
>task1: <NSThread: 0x10077ca60>{number = 3, name = (null)}<br>
task2: <NSThread: 0x10077d3e0>{number = 4, name = (null)}<br>
task2: <NSThread: 0x10077d3e0>{number = 4, name = (null)}<br>
task2: <NSThread: 0x10077d3e0>{number = 4, name = (null)}<br>
task1: <NSThread: 0x10077ca60>{number = 3, name = (null)}<br>
task1: <NSThread: 0x10077ca60>{number = 3, name = (null)}<br>
task3: <NSThread: 0x10077d3e0>{number = 4, name = (null)}<br>
task3: <NSThread: 0x10077d3e0>{number = 4, name = (null)}<br>
task3: <NSThread: 0x10077d3e0>{number = 4, name = (null)}<br>

### 5. NSOperation的其他操作
- 取消队列NSOperationQueue的所有操作，NSOperationQueue对象方法
```
- (void)cancelAllOperations
```
- 取消NSOperation的某个操作，NSOperation对象方法
```
- (void)cancel
```
- 使队列暂停或继续
```
// 暂停队列
[queue setSuspended:YES];
```
- 判断队列是否暂停
```
- (BOOL)isSuspended
```
__注意__：暂停和取消不是立刻取消当前操作，而是等当前的操作执行完之后不再进行新的操作。

### 6. NSOperation的操作依赖
NSOperation有一个非常好用的方法，就是操作依赖。可以从字面意思理解：某一个操作（operation2）依赖于另一个操作（operation1），只有当operation1执行完毕，才能执行operation2，这时，就是操作依赖大显身手的时候了。
```
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
```
输出结果：操作2总是在操作1之后执行，成功验证了上面的说法.
>operation1: <NSThread: 0x103d07d40>{number = 3, name = (null)}<br>
operation1: <NSThread: 0x103d07d40>{number = 3, name = (null)}<br>
operation1: <NSThread: 0x103d07d40>{number = 3, name = (null)}<br>
operation2: <NSThread: 0x103d07d40>{number = 3, name = (null)}<br>
operation2: <NSThread: 0x103d07d40>{number = 3, name = (null)}<br>
operation2: <NSThread: 0x103d07d40>{number = 3, name = (null)}<br>

[iOS多线程全套](https://www.jianshu.com/p/7649fad15cdb)   
[iOS多线程：『GCD』详尽总结](https://www.jianshu.com/p/2d57c72016c6)  
[linux线程结束函数对比说明join、cancel、kill、exit等](http://blog.sina.com.cn/s/blog_7880d3350102wuxz.html)