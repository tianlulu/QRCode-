//
//  ViewController.m
//  二维码生成与扫描
//
//  Created by lushuishasha on 16/8/11.
//  Copyright © 2016年 lushuishasha. All rights reserved.
//http://www.jianshu.com/p/85e131155b79

/**
 生成二维码步骤
 1.导入CoreImage框架(Xcode6.4居然不用导入)
 2.通过滤镜CIFilter生成二维码
 */
#import "ViewController.h"
#import "QRCodeView.h"

//#import <CoreImage/CoreImage.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *QRView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)setQRCode:(id)sender {
    [QRCodeView creatQRCodeWithUrlString:@"http://www.baidu.com" superView:self.QRView logoImage:[UIImage imageNamed:@"haha"]  logoImageSize:CGSizeMake(60, 60) logoImageWithCornerCornerRadius:0];
}


- (IBAction)scanQRCode:(id)sender {
    
}
@end
