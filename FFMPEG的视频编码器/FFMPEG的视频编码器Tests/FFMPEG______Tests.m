/*
 *FFmpeg编码h264
 *
 *赵彤彤 mrzhao12  ttdiOS
 *1107214478@qq.com
 *http://www.jianshu.com/u/fd9db3b2363b
 *本程序是iOS平台下FFmpeg对yuv编码h264
 *3.一定要添加#warn 这里的宽和高一定要和，yuv的分辨率宽高一致，不然会出现闪的绿色
 */
//  ViewController.h
//  FFMPEG的视频编码器
//
//  Created by ttdiOS on 16/6/17.
//  Copyright © 2016年 Abson. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FFMPEG______Tests : XCTestCase

@end

@implementation FFMPEG______Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
