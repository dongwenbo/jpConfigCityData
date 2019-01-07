//
//  ViewController.m
//  JobCitySQL
//
//  Created by qqxb_qinan on 2018/12/28.
//  Copyright © 2018年 DWB. All rights reserved.
//

#import "ViewController.h"
NSString * const jobCityInsertSQL = @"INSERT INTO [JobCity] ([ID],[Name],[AnotherName]) values (%zd,'%@','%@');";
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self NSURLSessionTest];

}
/// 向网络请求数据
- (void)NSURLSessionTest {
    // 1.创建url
    // 请求一个网页
    NSString *urlString = @"http://job.qinqinxiaobao.com/owner/district_city";
    
    // 一些特殊字符编码
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2.创建请求 并：设置缓存策略为每次都从网络加载 超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    // 3.采用苹果提供的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 4.由系统直接返回一个dataTask任务
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"%@",[NSThread currentThread]);
        if (data && (error == nil)) {
            // 网络访问成功
            //JSON
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *jsonData = [JSON objectForKey:@"data"];
            NSMutableArray *allSQLs = [[NSMutableArray alloc] init];
            for (NSDictionary *item in jsonData) {
                NSInteger cityId = [[item objectForKey:@"id"] integerValue];
                NSString *name = [item objectForKey:@"name"];
                NSArray *namePinYin = [item objectForKey:@"namePinYin"];
                NSString *anotherName = [namePinYin componentsJoinedByString:@","];
                NSString *sql = [NSString stringWithFormat:jobCityInsertSQL,cityId,name,anotherName];
                [allSQLs addObject:sql];
            }
            NSString *allSQL = [allSQLs componentsJoinedByString:@""];
            NSLog(@"%@",allSQL);
        } else {
            // 网络访问失败
            NSLog(@"error=%@",error);
        }
    }];
    
    // 5.每一个任务默认都是挂起的，需要调用 resume 方法
    [dataTask resume];
}
@end
