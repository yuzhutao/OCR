//
//  RecognizeManager.m
//  IDCardRecognition
//
//  Created by yu zhutao on 2019/8/13.
//  Copyright © 2019 zhongfeng. All rights reserved.
//

#import "RecognizeManager.h"
#import <TesseractOCR/TesseractOCR.h>
@interface RecognizeManager ()
{
    NSOperationQueue *m_operationQueue;
}
@end
@implementation RecognizeManager

+ (instancetype)shareManager
{
    static RecognizeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RecognizeManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    if (self = [super init])
    {
        m_operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)recognizeCardWithImage:(UIImage *)cardImage complete:(CompleteBlock)completeBlock
{
    // 扫描身份证图片，并进行预处理，定位号码区域图片并返回
//    UIImage *numberImage = [self opencvScanCard:cardImage];
//    //    UIImage *numberImage = cardImage;
//    if (numberImage == nil) {
//        completeBlock(numberImage, nil);
//    }
    
    
    // TesseractORC识别文字
    [self tesseractRecognizeImage:cardImage complete:^(UIImage *cropImage, NSString *numberText) {
        completeBlock(cardImage, numberText);
    }];
}

//- (UIImage *)opencvScanCard:(UIImage *)image
//{
//    // 将UIImage 转换成mat
//    cv::Mat resultImage;
//    UIImageToMat(image, resultImage);
//
//    // 转为灰度
//    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
//
//    // 利用阀值二值化
//    cv::threshold(resultImage, resultImage, 80, 255, CV_THRESH_BINARY);
//
//    // 腐蚀，填充（腐蚀背景）
//    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(26,26));
//    cv::erode(resultImage, resultImage, erodeElement);
//
//    // 轮廓检测
//    std::vector<std::vector<cv::Point>> contours; // 定义一个容器来存储所有检测到的轮廓
//    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
//
//    // 取出身份证号码区域
//    std::vector<cv::Rect> rects;
//    cv::Rect numberRect = cv::Rect(0,0,0,0);
//    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
//
//    for ( ; itContours != contours.end(); ++itContours) {
//        cv::Rect rect = cv::boundingRect(*itContours);
//        rects.push_back(rect);
//        //算法原理
//        if (rect.width > numberRect.width && rect.width > rect.height * 5) {
//            numberRect = rect;
//        }
//    }
//
//    //身份证号码定位失败
//    if (numberRect.width == 0 || numberRect.height == 0) {
//        return nil;
//    }
//    //定位成功成功，去原图截取身份证号码区域，并转换成灰度图、进行二值化处理
//    cv::Mat matImage;
//    UIImageToMat(image, matImage);
//    resultImage = matImage(numberRect);
//    //    resultImage = matImage;
//    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
//    cv::threshold(resultImage, resultImage, 80, 255, CV_THRESH_BINARY);
//    //将Mat转换成UIImage
//    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
//}

//利用TesseractOCR识别文字
- (void)tesseractRecognizeImage:(UIImage *)image complete:(CompleteBlock)completeBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
        tesseract.image = [image g8_blackAndWhite];
        tesseract.image = image;
        // Start the recognition
        [tesseract recognize];
        //执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(image, tesseract.recognizedText);
        });
    });
}

- (void)tesseractRecogniceWithImage:(UIImage *)inputImage complete:(CompleteBlock)complete
{
//    [self tesseractRecogniceWithImage:inputImage complete:complete];
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    operation.tesseract.image = inputImage;
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        NSString *recognizedText = tesseract.recognizedText;
        //执行回调
//        dispatch_async(dispatch_get_main_queue(), ^{
            complete(inputImage, recognizedText);
//        });
    };
    [m_operationQueue addOperation:operation];
//    operationQueue.addOperation(operation)
}
@end
