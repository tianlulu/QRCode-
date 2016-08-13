//
//  QRCodeView.m
//  二维码生成
//
//  Created by lushuishasha on 16/8/13.
//  Copyright © 2016年 lushuishasha. All rights reserved.
//

#import "QRCodeView.h"

@implementation QRCodeView
/**
 *  生成带logo的二维码
 *  二维码和logo都是正方形的
 *  @param urlString     二维码中的链接
 *  @param QRCodeCGRect  二维码的CGRect
 *  @param logoImage     二维码中的logo
 *  @param logoImageSize logo的大小
 *  @param cornerRadius  logo的圆角值大小
 *
 *  @return 生成的二维码
 */

+ (QRCodeView *)creatQRCodeWithUrlString:(NSString *)urlString superView:(UIView *)superView logoImage:(UIImage *)logoImage logoImageSize:(CGSize)logoImageSize
         logoImageWithCornerCornerRadius:(CGFloat)cornerRadius{
    // 先移除子视图
    QRCodeView *oldQRCodeView = [superView viewWithTag:123];
    [oldQRCodeView removeFromSuperview];
    
    QRCodeView *codeView = [[QRCodeView alloc] init];
    codeView.tag = 123;
    codeView.frame = CGRectMake(0, 0, superView.frame.size.width, superView.frame.size.height);
    CIImage *ciImage = [codeView setCIQRCodeGeneratorWithUrlString:urlString]; // 生成二维码
    UIImage *qrImage = [codeView createNonInterpolatedUIImageFormCIImage:ciImage withSize:superView.frame.size.width]; // 改变二维码的大小
    if (logoImage != nil) {
        if (cornerRadius < 0) {
            cornerRadius = 0;
            NSLog(@"cornerRadius 不能小于0");
        }
        qrImage = [codeView addImageToSuperImage:qrImage withSubImage:[codeView imageWithCornerRadius:cornerRadius image:logoImage] andSubImagePosition:CGRectMake((superView.frame.size.width - logoImageSize.width)/2, (superView.frame.size.height - logoImageSize.height)/2, logoImageSize.width, logoImageSize.height)]; // 增加logo
    }
    codeView.layer.contents = (__bridge id)qrImage.CGImage;
    [superView addSubview:codeView];
    return codeView;
}



//1.二维码基本设置
- (CIImage *)setCIQRCodeGeneratorWithUrlString:(NSString *)urlString{
    //1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //2.恢复滤镜的默认属性
    [filter setDefaults];
    
    // 3.通过KVO设置滤镜inputMessage数据
    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 4.通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    
    // 4.获得滤镜输出的图像
    CIImage *outPutImage = [filter outputImage];
    return outPutImage;
}



//2.生成高清二维码方法
/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
        
        // 创建bitmap;
        size_t width = CGRectGetWidth(extent) * scale;
        size_t height = CGRectGetHeight(extent) * scale;
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
        CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
        CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
        CGContextScaleCTM(bitmapRef, scale, scale);
        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        
        // 保存bitmap到图片
        CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
        CGContextRelease(bitmapRef);
        CGImageRelease(bitmapImage);
        
       // return [UIImage imageWithCGImage:scaledImage]; // 黑白图片
        UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
        return [self imageBlackToTransparent:newImage withRed:200.0f andGreen:70.0f andBlue:189.0f];
    }
}


//3.设置图片透明度以及颜色
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}



/**
 *  图片增加水印
 *
 *  @param superImage 需要增加水印的图片
 *  @param subImage   水印图片
 *  @param posRect    水印的位置 和 水印的大小
 *
 *  @return 加水印后的新图片
 */
- (UIImage *)addImageToSuperImage:(UIImage *)superImage withSubImage:(UIImage *)subImage andSubImagePosition:(CGRect)posRect{
    
    UIGraphicsBeginImageContext(superImage.size);
    [superImage drawInRect:CGRectMake(0, 0, superImage.size.width, superImage.size.height)];
    //四个参数为水印图片的位置
    [subImage drawInRect:posRect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}



/**
 *  图片设置圆角
 *
 *  @param cornerRadius 圆角值
 *  @param original     图片
 *
 *  @return 圆角图片
 */
- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius image:(UIImage *)image
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:cornerRadius] addClip];
    // 画图
    [image drawInRect:frame];
    // 获取新的图片
    UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return im;
}

@end
