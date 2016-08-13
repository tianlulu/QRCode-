//
//  QRCodeView.h
//  二维码生成与扫描
//
//  Created by lushuishasha on 16/8/13.
//  Copyright © 2016年 lushuishasha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
@interface QRCodeView : UIView

/**
 *  生成带logo的二维码
 *  二维码和logo都是正方形的
 *  @param urlString     二维码中的链接
 *  @param superView     二维码
 *  @param logoImage     二维码中的logo
 *  @param logoImageSize logo的大小
 *  @param cornerRadius  logo的圆角值大小
 *
 *  @return 生成的二维码
 */

+ (QRCodeView *)creatQRCodeWithUrlString:(NSString *)urlString superView:(UIView *)superView logoImage:(UIImage *)logoImage logoImageSize:(CGSize)logoImageSize logoImageWithCornerCornerRadius:(CGFloat)cornerRadius;
@end
