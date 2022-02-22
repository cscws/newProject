//
//  CSViewController.m
//  goodboy
//
//  Created by 闪闪的少女 on 2022/2/7.
//

#import "CSViewController.h"
#import "Student.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>

@class CSViewController;
typedef void(^myblock4)(void);

@interface CSViewController ()
@property (nonatomic, strong) Student *stu;
@property (nonatomic, assign) int ticketSurplusCount;
@property (nonatomic, strong) void (^myBlock)(void);
@property (nonatomic, strong) void (^myBlock2) (NSString *);
@property (nonatomic, strong) NSString*(^myBlock3) (NSString *);
@end

@implementation CSViewController
{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self xxxKvo];
//    PHAsset *ss;
//    PHImageManager *pma;
//    [self xxxGCD];
//    [self apply];
    [self initTicketStatusSave];
    
    _myBlock = ^{
        
    };
    _myBlock2 = ^(NSString *str){
        
    };
    _myBlock3 = ^(NSString *str){
        return @"xxx";
    };
}

- (void)xxxGCD{
    
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("test2.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{    // 异步执行 + 串行队列
        dispatch_sync(queue2, ^{  // 同步执行 + 串行队列2
            // 追加任务 1
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
    
//    dispatch_queue_t que = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(que, ^{
//        dispatch_async(que, ^{
//
//            NSLog(@"--异步--%@",que);
//        });
//
//        NSLog(@"--异步串联--%@",que);
//    });
}

/**
 * 线程安全：使用 semaphore 加锁
 * 初始化火车票数量、卖票窗口（线程安全）、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    self.ticketSurplusCount = 10;
   dispatch_semaphore_t semaphoreLock = dispatch_semaphore_create(1);
        
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafecount:semaphoreLock];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafecount:semaphoreLock];
    });
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafecount:semaphoreLock];
    });
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafecount:semaphoreLock];
    });
}

/**
 * 售卖火车票（线程安全）
 */
- (void)saleTicketSafecount:(dispatch_semaphore_t )semaphoreLock{
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {  // 如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { // 如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            
            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
            break;
        }
        
        // 相当于解锁
        dispatch_semaphore_signal(semaphoreLock);
    }
}

- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}

- (void)xxxKvo{
    _stu = [[Student alloc] init];
    NSLog(@"self->isa:%@",object_getClass(_stu));
    NSLog(@"self class:%@",[_stu class]);
    NSLog(@"ClassMethodNames=%@",ClassMethodNames(object_getClass(_stu)));
    [_stu addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"self->isa:%@",object_getClass(_stu));
    NSLog(@"self class:%@",[_stu class]);
    NSLog(@"ClassMethodNames=%@",ClassMethodNames(object_getClass(_stu)));
}

static NSArray * ClassMethodNames(Class c)
{
    NSMutableArray * array = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method * methodList = class_copyMethodList(c, &methodCount);
    unsigned int i;
    for(i = 0; i < methodCount; i++) {
        [array addObject: NSStringFromSelector(method_getName(methodList[i]))];
    }
    
    free(methodList);
    return array;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_stu removeObserver:self forKeyPath:@"name"];
}

@end
