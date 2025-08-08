//
//  TFY_AudioPlayer.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/3/22.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "TFY_Utils.h"

@implementation TFY_ImageModel
@end

@implementation TFY_AudioPlayer

static NSMutableDictionary *_soundIDs;
+(NSMutableDictionary *)soundIDs{
    if(!_soundIDs){
        _soundIDs = [NSMutableDictionary dictionary];
    }
    return _soundIDs;
}

+(void)playSound:(NSString*)filename {
    if(!filename) return;
    SystemSoundID soundID = [[self soundIDs][filename] unsignedIntValue];
    if(!soundID){
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if(!url) return;
        OSStatus status=AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
        NSLog(@"%d",status);  //0 代表成功
        [self soundIDs][filename] = @(soundID);
    }
    //播放
    AudioServicesPlaySystemSound(soundID);
}

+(void)disposeSound:(NSString*)filename{
    if(!filename) return;
    SystemSoundID soundID = [[self soundIDs][filename] unsignedIntValue];
    if(soundID){
        AudioServicesDisposeSystemSoundID(soundID);
        [[self soundIDs] removeObjectForKey:filename];
    }
}

static NSMutableDictionary *_musicPlayers;
+(NSMutableDictionary *)musicPlayers{
    if(!_musicPlayers){
        _musicPlayers = [NSMutableDictionary dictionary];
    }
    return _musicPlayers;
}

+ (BOOL)playMusic:(NSString *)filename {
    if(!filename) return NO;
    AVAudioPlayer *player = [self musicPlayers][filename];
    if(!player){
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if(!url) return NO;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        if(![player prepareToPlay]) return NO;
        [self musicPlayers][filename]=player;
    }
    if(!player.isPlaying){
        return [player play];
    }
    return YES;
}

+ (void)pauseMusic:(NSString *)filename{
    if(!filename) return;
    AVAudioPlayer * player = [self musicPlayers][filename];
    if(player.isPlaying){
        [player pause];
    }
}

+ (void)stopMusic:(NSString *)filename{
    if(!filename) return;
    AVAudioPlayer * player = [self musicPlayers][filename];
    [player stop];
    [[self musicPlayers] removeObjectForKey:filename];
}

static NSMutableDictionary *_imageDict;
+(NSMutableDictionary *)imageDict {
    if(!_imageDict){
        _imageDict = [NSMutableDictionary dictionary];
    }
    return _imageDict;
}

+ (void)creatGroupUrl:(NSArray<NSString *> *)urlArray widthImage:(CGFloat)imageWidth imageArr:(void(^)(NSArray<TFY_ImageModel *> *images))imageHandle
{
    __block NSMutableArray<TFY_ImageModel *> *groupImages = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_queue_create("downloadImages", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        dispatch_semaphore_t disp = dispatch_semaphore_create(0);//创建信号
        [urlArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TFY_ImageModel *imageCacheModel = [self imageDict][obj];
            if (imageCacheModel != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [groupImages addObject:imageCacheModel];
                    if (groupImages.count == urlArray.count) {
                        dispatch_semaphore_signal(disp);//发送信号
                    }
                });
            } else {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:obj]];
                __block UIImage *image = nil;
                NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error) {
                        image = [UIImage imageNamed:@"home_recommendedDaily"];
                    }else{
                        image = [UIImage imageWithData:data];
                    }
                    if (!image){
                        image = [UIImage imageNamed:@"home_recommendedDaily"];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        TFY_ImageModel *model = TFY_ImageModel.new;
                        model.image = image;
                        model.imageSize = image.size;
                        model.imageH = [self heightForImage:image widht_w:imageWidth];
                        model.imageUrl = obj;
                        model.imageData = data;
                        [groupImages addObject:model];
                        [self imageDict][obj] = model;
                        if (groupImages.count == urlArray.count) {
                            dispatch_semaphore_signal(disp);//发送信号
                        }
                    });
                }];
                [dataTask resume];
            }
        }];
        // 信号等待
        dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageHandle) {
                imageHandle(groupImages);
            }
        });
    });
}

+ (CGFloat)heightForImage:(UIImage *)image widht_w:(CGFloat)widht_w {
    //(1)获取图片的大小
    CGSize size = image.size;
    //(2)求出缩放比例
    CGFloat scale = widht_w / size.width;
    CGFloat imageHeight = size.height * scale;
    return imageHeight;
}


@end
