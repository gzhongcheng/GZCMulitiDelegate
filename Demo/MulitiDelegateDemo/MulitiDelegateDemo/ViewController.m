//
//  ViewController.m
//  MulitiDelegateDemo
//
//  Created by ZhongCheng Guo on 2019/1/31.
//  Copyright © 2019 ZhongCheng Guo. All rights reserved.
//

#import "ViewController.h"
#import "DemoManager.h"

@interface ViewController ()<DemoDelegate>

@property (nonatomic, assign) int index;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = [NSString stringWithFormat:@"%d",self.index];
    [[DemoManager sharedManager]addDelegate:self];
    self.view.backgroundColor = [DemoManager sharedManager].themesColor;
}


- (UIColor *)randomColor {
    // 生成随机颜色
    CGFloat hue = arc4random() % 100 / 100.0; //色调：0.0 ~ 1.0
    CGFloat saturation = (arc4random() % 50 / 100) + 0.5; //饱和度：0.5 ~ 1.0
    CGFloat brightness = (arc4random() % 50 / 100) + 0.5; //亮度：0.5 ~ 1.0
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (IBAction)changeThemes:(id)sender {
    [DemoManager sharedManager].themesColor = [self randomColor];
}

- (IBAction)getProgress:(id)sender {
    CGFloat progress = [[DemoManager sharedManager] getProgress];
    self.progressLabel.text = [NSString stringWithFormat:@"获取到的进度为:\n%.2f%%",progress*100];
}

- (IBAction)nextVC:(id)sender {
    // 使用Storyboard创建VC
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *newVC = [story instantiateViewControllerWithIdentifier:@"ViewController"];
    newVC.index = self.index + 1;
    [self.navigationController pushViewController:newVC animated:YES];
}

- (int)themesColorChanged:(UIColor *)themesColor{
    // 需要注意的是这里是异步调用，改变颜色需要在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.backgroundColor = themesColor;
    });
    return self.index;
}

- (CGFloat)somethingProgress{
    return random()%80;
}


@end
