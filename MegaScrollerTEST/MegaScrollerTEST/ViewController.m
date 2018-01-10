//
//  ViewController.m
//  MegaScrollerTEST
//
//  Created by pidi on 2018/1/10.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//

#import "ViewController.h"
#import "MegaScroller.h"

@interface ViewController ()<MegaScrollerDataSource,MegaScrollerDelegate>

@property(nonatomic,strong)MegaScroller *scroller;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configuration];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)configuration{
    _scroller = [MegaScroller megaScrollerWithframe:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 60) andDelegate:self initialIndex:0];
    [self.view addSubview:_scroller];
}


#pragma mark -- DATASOURCE & DELAGATE

-(NSInteger)numbersOfPageIn:(MegaScroller *)scroller{
    return 10;
}


-(NSString *)protypeOf:(MegaScroller *)scroller from:(NSInteger)index{
    if (index % 2 == 0) {
        return NSStringFromClass([UILabel class]);
    }
    else{
        return NSStringFromClass([UIView class]);
    }

}


-(void)didInitOf:(UIView *)mView inthe:(MegaScroller *)scroller{
    if ([mView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)mView;
        label.text = @"I am a Label";
        label.backgroundColor = [UIColor cyanColor];
         label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 3;
    }
    else{
        UILabel *label =[UILabel new];
        label.frame = mView.bounds;
        label.textAlignment = NSTextAlignmentCenter;
        mView.backgroundColor = [UIColor blueColor];
        [mView addSubview:label];
        label.numberOfLines = 3;
    }
}

-(void)didAppearOfView:(UIView *)mView From:(NSInteger)index inthe:(MegaScroller *)scroller{
    if ([mView isKindOfClass:[UILabel class]]) {
       UILabel *label = (UILabel *)mView;
        label.text = [NSString stringWithFormat:@"I am a Label Prototype style,And my currrent index is %li",index];
    }
    else{
      UILabel *label = (UILabel *) [[mView subviews] lastObject];
       label.text = [NSString stringWithFormat:@"I am a UIView Prototype style,And my currrent index is %li",index];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
