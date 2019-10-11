//
//  RecognizeManager.h
//  IDCardRecognition
//
//  Created by yu zhutao on 2019/8/13.
//  Copyright © 2019 zhongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN
@class UIImage;
@interface RecognizeManager : NSObject

typedef void (^CompleteBlock) (UIImage * _Nullable cropImage, NSString * _Nullable text);

+ (instancetype)shareManager;

- (void)recognizeCardWithImage:(UIImage *)cardImage complete:(CompleteBlock)completeBlock;

- (void)tesseractRecogniceWithImage:(UIImage *)inputImage complete:(CompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
