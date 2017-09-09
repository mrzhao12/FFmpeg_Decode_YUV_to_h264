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

@interface FFMPEG______UITests : XCTestCase

@end

@implementation FFMPEG______UITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
