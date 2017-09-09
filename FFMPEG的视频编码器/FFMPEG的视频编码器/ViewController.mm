/*
 *FFmpeg编码h264
 *
 *赵彤彤 mrzhao12  ttdiOS
 *1107214478@qq.com
 *http://www.jianshu.com/u/fd9db3b2363b
 *本程序是iOS平台下FFmpeg对yuv编码h264
 *3.一定要添加#warn 这里的宽和高一定要和，yuv的分辨率宽高一致，不然会出现闪的绿色
 */
//  ViewController.m
//  FFMPEG的视频编码器
//
//  Created by ttdiOS on 16/6/17.
//  Copyright © 2016年 Abson. All rights reserved.
//

#import "ViewController.h"
#include <iostream>

#ifdef __cplusplus
extern "C"
{
#endif
#include <libavutil/opt.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libavutil/avstring.h>
#include <libavformat/url.h>
#include "x264.h"
#ifdef __cplusplus
};
#endif

int flush_encoder(AVFormatContext *fmt_ctx,unsigned int stream_index){
    int ret;
    int got_frame;
    AVPacket enc_pkt;
    if (!(fmt_ctx->streams[stream_index]->codec->codec->capabilities &
          CODEC_CAP_DELAY))
        return 0;
    while (1) {
        enc_pkt.data = NULL;
        enc_pkt.size = 0;
        av_init_packet(&enc_pkt);
        ret = avcodec_encode_video2 (fmt_ctx->streams[stream_index]->codec, &enc_pkt,
                                     NULL, &got_frame);
        av_frame_free(NULL);
        if (ret < 0)
            break;
        if (!got_frame){
            ret=0;
            break;
        }
        printf("Flush Encoder: Succeed to encode 1 frame!\tsize:%5d\n",enc_pkt.size);
        /* mux encoded frame */
        ret = av_write_frame(fmt_ctx, &enc_pkt);
        if (ret < 0)
            break;
    }
    return ret;
}


@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    yuvCodecToVideoH264(NULL);
//    AVInputFormat *input = av_find_input_format("yuv");

}



AVOutputFormat *guess_format(const char *short_name, const char *filename,
                             const char *mime_type)
{
    AVOutputFormat *fmt = NULL, *fmt_found;
    int score_max, score;

    /* specific test for image sequences */
#if CONFIG_IMAGE2_MUXER
    if (!short_name && filename &&
        av_filename_number_test(filename) &&
        ff_guess_image2_codec(filename) != AV_CODEC_ID_NONE) {
        return av_guess_format("image2", NULL, NULL);
    }
#endif
    /* Find the proper file type. */
    fmt_found = NULL;
    score_max = 0;
    while ((fmt = av_oformat_next(fmt))) {
        score = 0;
        if (fmt->name && short_name && av_match_name(short_name, fmt->name))
            score += 100;
        if (fmt->mime_type && mime_type && !strcmp(fmt->mime_type, mime_type))
            score += 10;
        if (filename && fmt->extensions &&
            av_match_ext(filename, fmt->extensions)) {
            score += 5;
        }
        if (score > score_max) {
            score_max = score;
            fmt_found = fmt;
        }
    }
    return fmt_found;
}


AVOutputFormat *oformat_next(const AVOutputFormat *f)
{
    if (f)
        return f->next;
    else
        return (AVOutputFormat *)malloc(sizeof(struct AVOutputFormat));
}

int amatch(const char *name, const char *names)
{
    const char *p;
    int len, namelen;

    if (!name || !names)
        return 0;

    namelen = (int)strlen(name);
    while (*names) {
        int negate = '-' == names[0];
        p = strchr(names, ',');
        if (!p)
            p = names + strlen(names);
        names += negate;
        len = FFMAX((int)(p - names), namelen);
        if (!strncasecmp(name, names, len) || !strncmp("ALL", names, FFMAX(3, p - names)))
            return !negate;
        names = p + (p[0] == ',');
    }
    return 0;
}

int strncasecmp(const char *a, const char *b, size_t n)
{
    const char *end = a + n;
    uint8_t c1, c2;
    do {
        c1 = av_tolower(*a++);
        c2 = av_tolower(*b++);
    } while (a < end && c1 && c1 == c2);
    return c1 - c2;


}

void yuvCodecToVideoH264(const char *input_file_name)
{
    AVFormatContext* pFormatCtx;
    AVOutputFormat* fmt;
    AVStream* video_st;
    AVCodecContext* pCodecCtx;
    AVCodec* pCodec;
    AVPacket pkt;
    uint8_t* picture_buf;
    AVFrame* pFrame;
    int picture_size;
    int y_size;
    int framecnt=0;
        char info[1000]={0};
    //FILE *in_file = fopen("src01_480x272.yuv", "rb"); //Input raw YUV data

//    const char *input_file = [[[NSBundle mainBundle] pathForResource:@"1280x720_park" ofType:@"yuv"]  cStringUsingEncoding:NSUTF8StringEncoding];
//       const char *input_file = [[[NSBundle mainBundle] pathForResource:@"521" ofType:@"flv"]  cStringUsingEncoding:NSUTF8StringEncoding];
     const char *input_file = [[[NSBundle mainBundle] pathForResource:@"ds_480x272的副本" ofType:@"yuv"]  cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *in_file = fopen(input_file, "rb");   //Input raw YUV data
//    int in_w=480,in_h=272;                              //Input data's width and height
//       int in_w=1280,in_h=720;
//     int in_w=848,in_h=480;
//         int in_w=320,in_h=240;
//#warn 这里的宽和高一定要和，yuv的分辨率宽高一致，不然会出现闪的绿色
     int in_w=480,in_h=272;
    int framenum=100;                                   //Frames to encode
    //const char* out_file = "src01.h264";              //Output Filepath
    //const char* out_file = "src01.ts";
    //const char* out_file = "src01.hevc";
    const char* out_file = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"dsss_480x272的副本.264"] cStringUsingEncoding:NSUTF8StringEncoding];

    av_register_all();
    //Method1.
    pFormatCtx = avformat_alloc_context();

    //Guess Format
    fmt = av_guess_format(NULL, out_file, NULL);
    pFormatCtx->oformat = fmt;

    // Method 2.
    // avformat_alloc_output_context2(&pFormatCtx, NULL, NULL, out_file);
    // fmt = pFormatCtx->oformat;

    //Open output URL
    if (avio_open(&pFormatCtx->pb,out_file, AVIO_FLAG_READ_WRITE) < 0){
        printf("Failed to open output file! \n");
        return;
    }

    video_st = avformat_new_stream(pFormatCtx, 0);
    video_st->time_base.num = 1;
    video_st->time_base.den = 25;

    if (video_st==NULL){
        return ;
    }
    //Param that must set
    pCodecCtx = video_st->codec;
    //pCodecCtx->codec_id =AV_CODEC_ID_HEVC;
    pCodecCtx->codec_id = fmt->video_codec;
    pCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
    pCodecCtx->pix_fmt = AV_PIX_FMT_YUV420P;
//    sprintf(info, "%s[Resolution]%dx%d\n",info, pCodecCtx->width,pCodecCtx->height);
//    printf("new$$$$$$$$%s",info);

    pCodecCtx->width = in_w;
    pCodecCtx->height = in_h;
    pCodecCtx->bit_rate = 400000;
    pCodecCtx->gop_size=250;

    pCodecCtx->time_base.num = 1;
    pCodecCtx->time_base.den = 25;

    //H264
    //pCodecCtx->me_range = 16;
    //pCodecCtx->max_qdiff = 4;
    //pCodecCtx->qcompress = 0.6;
    pCodecCtx->qmin = 10;
    pCodecCtx->qmax = 51;

    //Optional Param
    pCodecCtx->max_b_frames=3;

    // Set Option
    AVDictionary *param = 0;
    //H.264
    if(pCodecCtx->codec_id == AV_CODEC_ID_H264) {
        av_dict_set(&param, "preset", "slow", 0); // 通过--preset的参数调节编码速度和质量的平衡。
        av_dict_set(&param, "tune", "zerolatency", 0); // 通过--tune的参数值指定片子的类型，是和视觉优化的参数，或有特别的情况。
        // 零延迟，用在需要非常低的延迟的情况下，比如电视电话会议的编码
        //av_dict_set(¶m, "profile", "main", 0);
    }
    //H.265
    if(pCodecCtx->codec_id == AV_CODEC_ID_H265){
        av_dict_set(&param, "preset", "ultrafast", 0);
        av_dict_set(&param, "tune", "zero-latency", 0);
    }

    //Show some Information
    av_dump_format(pFormatCtx, 0, out_file, 1);

    pCodec = avcodec_find_encoder(pCodecCtx->codec_id);
    if (!pCodec){
        printf("Can not find encoder! \n");
        return;
    }
    if (avcodec_open2(pCodecCtx, pCodec,&param) < 0){
        printf("Failed to open encoder! \n");
        return;
    }


    pFrame = av_frame_alloc();
    picture_size = avpicture_get_size(pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height);
    picture_buf = (uint8_t *)av_malloc(picture_size);
    avpicture_fill((AVPicture *)pFrame, picture_buf, pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height);
   sprintf(info, "%s[Resolution]%dx%d\n",info, pCodecCtx->width,pCodecCtx->height);
      printf("$$$$$$$$%s",info);
    //Write File Header
    int ret = avformat_write_header(pFormatCtx,NULL);
    if (ret < 0) {
        printf("write header is failed");
        return;
    }

    av_new_packet(&pkt,picture_size);

    y_size = pCodecCtx->width * pCodecCtx->height;

    for (int i=0; i<framenum; i++){
        //Read raw YUV data
        if (fread(picture_buf, 1, y_size*3/2, in_file) <= 0){
            printf("Failed to read raw data! \n");
            return ;
        }else if(feof(in_file)){
            break;
        }
        pFrame->data[0] = picture_buf;              // Y
        pFrame->data[1] = picture_buf+ y_size;      // U
        pFrame->data[2] = picture_buf+ y_size*5/4;  // V
        //PTS
        //pFrame->pts=i;
        pFrame->pts=i*(video_st->time_base.den)/((video_st->time_base.num)*25);
        int got_picture=0;
        //Encode
        int ret = avcodec_encode_video2(pCodecCtx, &pkt,pFrame, &got_picture);
        if(ret < 0){
            printf("Failed to encode! \n");
            return ;
        }
        if (got_picture==1){
            printf("Succeed to encode frame: %5d\tsize:%5d\n",framecnt,pkt.size);
            framecnt++;
            pkt.stream_index = video_st->index;
            ret = av_write_frame(pFormatCtx, &pkt);
            av_free_packet(&pkt);
        }
    }
    //Flush Encoder
    int ret2 = flush_encoder(pFormatCtx,0);
    if (ret2 < 0) {
        printf("Flushing encoder failed\n");
        return;
    }
    
    //Write file trailer
    av_write_trailer(pFormatCtx);

    //Clean
    if (video_st){
        avcodec_close(video_st->codec);
        av_free(pFrame);
        av_free(picture_buf);
    }
    avio_close(pFormatCtx->pb);
    avformat_free_context(pFormatCtx);

    fclose(in_file);
    //
    //    x264_param_t *xparam = malloc(sizeof(x264_param_t));
    //    x264_param_default(xparam);
    //    x264_param_default_preset(xparam, "slower", "zerolatency");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


















//int main(int argc, const char * argv[]) {
//    printf("ffffff44_____________");
//    //    @autoreleasepool {
//    //        void *p;
//    //        {
//    //            ABSClass *objc = [[ABSClass alloc]init];
//    //            objc.name = @"我们";
//    //            p = (__bridge void*)objc;
//    //        }
//    //        NSLog(@"%@", [(__bridge ABSClass *)p name]);
//    //    }
//    return 0;
//}













@end



