//
//  ResultDetialController.m
//  JYVivoUI2
//
//  Created by jock li on 16/5/2.
//  Copyright © 2016年 timedge. All rights reserved.
//

#import "ResultDetialController.h"
#import "JYVivoUI2.h"
#import "UIResultItemLabel.h"
#import "o_ResponseMode.h"
#import "idCardAdoptMode.h"


// 返回信息中对特定照片的命名
const NSString* SelfPhotoName = @"现场照";
const NSString* IDPhotoName = @"证件照";
const NSString* LivePhotoName = @"活体检测";
const NSString* LibPhotoName = @"库里照";

@interface ResultDetialController () <UIScrollViewDelegate>
{
    NSUInteger _resultTitleCount;
}

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *resultsScrollView;

@property (weak,nonatomic) UILabel *detailsLabel;//显示详情的label

//重新开始按钮属性
@property (strong, nonatomic) IBOutlet UIButton *restartBtn;



@end

@implementation ResultDetialController
- (IBAction)backBtn:(id)sender
{

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)backButton:(id)sender {
    [self.presentingViewController.presentingViewController.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (UIImage *)imageOrientation:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newPic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageControl.numberOfPages = 0;
    
    
    idCardAdoptMode *iAMode = [[idCardAdoptMode alloc] init];
    // 生成图片信息
    UIImage *idCardImage = iAMode.idCardImage;
    idCardImage = [UIImage imageWithCGImage:idCardImage.CGImage scale:1 orientation:UIImageOrientationRight];//照片转向
    
    UIImage *sceneImage = [UIImage imageWithData:iAMode.sceneData];
    sceneImage = [UIImage imageWithCGImage:sceneImage.CGImage scale:1 orientation:UIImageOrientationUp];
    
    [self addPhotoToScrollbar:idCardImage withLabel:[IDPhotoName copy]];
    
    [self addPhotoToScrollbar:sceneImage withLabel:[SelfPhotoName copy]];
    
    for (NSUInteger i=0; i<iAMode.photos.count; i++)
    {
//        [self addPhotoToScrollbar:[self.personInfo.photos objectAtIndex:i] withLabel:[LivePhotoName copy]];
        [self addPhotoToScrollbar:[iAMode.photos objectAtIndex:i] withLabel:[[NSString alloc]initWithFormat:@"活体检测%ld", i+1]];
    }
    
    // 按结果代码生成结果标签

    for (int i=0; i<iAMode.resultInfos.count; i++)
    {
        o_ResponseMode *mode = [iAMode.resultInfos objectAtIndex:i];
        
        if (mode.o_responseNumber == 1)
        {
            [self addResultTitle:[[NSString alloc]initWithFormat:@"L1:%@", [mode.o_response objectForKey:@"info"]] by:([[mode.o_response objectForKey:@"code"] intValue] == 0)];
        }
        else if(mode.o_responseNumber == 2)
        {
            [self addResultTitle:[[NSString alloc]initWithFormat:@"L2:%@", [mode.o_response objectForKey:@"info"]] by:([[mode.o_response objectForKey:@"code"] intValue] == 0)];
        }
        else if(mode.o_responseNumber == 3)
        {
            [self addResultTitle:[[NSString alloc]initWithFormat:@"L3:%@", [mode.o_response objectForKey:@"info"]] by:([[mode.o_response objectForKey:@"code"] intValue] == 0)];
        }
    }
    if (self.detailsLabel==nil&&iAMode.resultInfos.count==0&&iAMode.info!= nil)
    {
        UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.pageScrollView.frame.origin.y+self.pageScrollView.frame.size.height+10, self.view.frame.size.width, 50)];
        
        detailsLabel.textColor = [UIColor redColor];
        detailsLabel.textAlignment = NSTextAlignmentCenter;//居中显示
        detailsLabel.text = iAMode.info;
        
        [self.view addSubview:detailsLabel];
        self.detailsLabel = detailsLabel;
    }
    
    //圆角
    self.restartBtn.layer.cornerRadius = 15;
    self.restartBtn.layer.masksToBounds = YES;
}

-(void)addResultTitle:(NSString*)title by:(BOOL)success
{

    UIResultItemLabel *itemLabel = [[UIResultItemLabel alloc] initWithLabel:title success:success];
    
    _resultTitleCount++;//增加起始距离
    
    itemLabel.frame = CGRectMake((self.view.frame.size.width - 240)/2,self.pageScrollView.frame.origin.y+self.pageScrollView.frame.size.height + _resultTitleCount * 30, 240, 26);
    
    [self.view addSubview:itemLabel];
    

}

-(void)addPhotoToScrollbar:(UIImage*)image withLabel:(NSString*)title
{

    NSInteger page = self.pageControl.numberOfPages;
    
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(page * 240, 12, 240, 20);
    label.textColor = GOOD_UICOLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    imageView.frame = CGRectMake(page * 240, 32, 240, 308);
    
    
    [self.pageScrollView addSubview:label];
    [self.pageScrollView addSubview:imageView];
    
    self.pageControl.numberOfPages = ++page;
    
    [self.pageScrollView setContentSize:CGSizeMake(240 * page, 340)];
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    NSInteger page = scrollView.contentOffset.x / 240;
    if (page != self.pageControl.currentPage)
    {
        self.pageControl.currentPage = page;
    }
}

- (IBAction)back:(id)sender {

}

@end
