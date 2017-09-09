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

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
