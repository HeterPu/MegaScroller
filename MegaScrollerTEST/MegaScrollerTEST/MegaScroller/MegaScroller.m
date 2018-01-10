//
//  MegaScroller.m
//
//  Created by pi on 2017/6/13.
//  Copyright © 2017年 Peter Hu. All rights reserved.
//  Github HomePage: https://github.com/HeterPu/MegaScroller
//  Like It ,Star It !
//

#import "MegaScroller.h"

 //为了在目录等于0时可以响应
#define K_View_Appear_Active_Offset 2

@interface MegaScroller()<UIScrollViewDelegate>

@property (weak, nonatomic) id<MegaScrollerDelegate> dataDelegate;
@property (weak, nonatomic) id<MegaScrollerDataSource> dataSource;
@property(assign,nonatomic)NSInteger currentIndex;
@property(assign,nonatomic)NSInteger realTimeIndex;
@property(strong,nonatomic) NSMutableArray *classArra;
@property(assign,nonatomic)NSInteger lastX;
@property(strong,nonatomic)NSMutableDictionary *cachePool;
@property(strong,nonatomic)NSDictionary *pageClassDict;
@property (assign,nonatomic)NSInteger numberOfpage;


/**
 是否第一次进入,用于解决动画滚动时的手势禁用问题
 */
@property (assign,nonatomic)BOOL firstEnterFlag;


/**
 是否动画显示滚动
 */
@property(nonatomic,strong)NSNumber *isAnimatedMove;


@end


@implementation MegaScroller

+(instancetype)megaScrollerWithframe:(CGRect)frame andDelegate:(id<MegaScrollerDataSource,MegaScrollerDelegate>)delegate initialIndex:(NSInteger)initialIndex {
    MegaScroller *instance = [[MegaScroller  alloc]initWithFrame:frame];
    if (instance) {
        instance.dataDelegate = delegate;
        instance.dataSource = delegate;
        instance.delegate = instance;
        instance.cachePool = [NSMutableDictionary dictionary];
        [instance initializationWithInitialIndex:initialIndex];
    }
    return instance;
}


-(void)initializationWithInitialIndex:(NSInteger)index{
    if (_dataSource&&([_dataSource respondsToSelector:@selector(numbersOfPageIn:)])) {
        __weak typeof (self) weakSelf = self;
        _classArra = [NSMutableArray array];
        NSInteger integer = [_dataSource numbersOfPageIn:weakSelf];
        self.numberOfpage = integer;
        if (integer > 0) {
            self.contentSize = CGSizeMake(self.frame.size.width * integer, 0);
            self.pagingEnabled = true;
            //若目录大于总数量，设置为0;
            if (index > integer - 1) index = 0;
            _currentIndex = index;
            _realTimeIndex = index;
            [self initWithIndex:index];
            UIView *originView = [self viewWithTag:10 + index];
            if (originView)[self setDefaultPreLoadPageWithView:originView index:index];
        }
    }
}



-(NSString *)fetchClassWith:(NSInteger)index{
    __weak typeof (self) weakSelf = self;
    if (index < self.pageClassDict.count) {
        return [_pageClassDict objectForKey:[NSString stringWithFormat:@"%li",index]];
    }
    else
    {
        if ([_dataSource respondsToSelector:@selector(protypeOf:from:)]) {
            NSString *class = [_dataSource protypeOf:weakSelf from:index];
            if (class) {
                [_pageClassDict setValue:class forKey:[NSString stringWithFormat:@"%li",index]];
            }
            return class;
        }
        else
        {
            return nil;
        }
        
    }
}



-(void)initWithIndex:(NSInteger)index {
    __weak typeof (self) weakSelf = self;
//    self.isAnimatedMove = @(false);
    NSLog(@"MegaScroller Init with index %li",index);
    NSString *class = [self fetchClassWith:index];
    if (class) {
        Class clas = NSClassFromString(class);
        UIView *view = [[clas  alloc]init];
        view.tag = 10 + index;
        [self addView:view withIndex:index];
        if (_dataSource) {
            [_dataSource didInitOf:view inthe:weakSelf];
        }
        [self.pageClassDict setValue:class forKey:[NSString stringWithFormat:@"%li",index]];
    }
}


/**
 初始化视图的运行时

 @param view 视图
 @param index 目录
 */
-(void)setDefaultPreLoadPageWithView:(UIView *)view index:(NSInteger )index{
    if (_dataDelegate) {
        __weak typeof (self) weakSelf = self;
        if ([self.dataDelegate respondsToSelector:@selector(willAppearOfView: From:inthe:)]) {
            [self.dataDelegate willAppearOfView:view From:index inthe:weakSelf];
        }
        if ([self.dataDelegate respondsToSelector:@selector(didAppearOfView: From:inthe:)]) {
            [self.dataDelegate didAppearOfView:view From:index inthe:weakSelf];
            [self setContentOffset:CGPointMake(self.bounds.size.width * index, 0) animated:false];
        }
    }
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


#pragma mark -- 缓存View相关逻辑

/**
 缓存视图
 @param index 目录
 */
-(void)cacherViewWith:(NSInteger)index{
    UIView *view = [self viewWithTag:index + 10];
    if(view){
        [self enQueueView:index];
        NSLog(@"MegaScroller encache view index %li",index);
    }
}


/**
 缓存到队列
 @param index 目录
 */
-(void)enQueueView:(NSInteger)index{
    UIView *cacheView = [self viewWithTag:index + 10];
    [self enQueueWithView:cacheView];
}

/**
 缓存到视图
 @param cacheView 缓存的视图
 */
-(void)enQueueWithView:(UIView *)cacheView{
    if (!cacheView) {
        return;
    }
     __weak typeof (self) weakSelf = self;
    if ([_dataDelegate respondsToSelector:@selector(clearBeforeDecache:inthe:)]) {
        [_dataDelegate clearBeforeDecache:cacheView inthe:weakSelf];
    }
    
    NSMutableArray *cacheArra = [self.cachePool objectForKey:NSStringFromClass([cacheView class])];
    if (cacheArra) {
        [cacheArra addObject:cacheView];
    }
    else
    {
        cacheArra = [NSMutableArray array];
        [cacheArra addObject:cacheView];
        [self.cachePool setObject:cacheArra forKey:NSStringFromClass([cacheView class])];
    }
    [cacheView removeFromSuperview];
}


/**
 取出缓存
 @param index 目录
 */
-(void)deCacheViewWith:(NSInteger)index{
    UIView *view = [self viewWithTag:index + 10];
    if (!view) {
        [self deQueueView:index];
        NSLog(@"MegaScroller decache view index is %li",index);
    }
}

/**
 从队列中取出缓存
 @param index 目录
 */
-(void)deQueueView:(NSInteger)index {
    NSString *class = [self fetchClassWith:index];
    if (class) {
        NSMutableArray *cacheArra = [self.cachePool objectForKey:class];
        if (cacheArra &&(cacheArra.count > 0)) {
            UIView *cacheView = [cacheArra lastObject];
            [self addView:cacheView withIndex:index];
            [cacheArra removeLastObject];
        }
        else
        {
            [self initWithIndex:index];
        }
    }
    else
    {
        [self initWithIndex:index];
    }
}


/**
 添加视图到自己，取出缓存后会添加到本地
 @param view 添加的视图
 @param index 添加的目录
 */
-(void)addView:(UIView *)view withIndex:(NSInteger)index {
    view.frame = CGRectMake(self.frame.size.width * index, 0, self.frame.size.width, self.frame.size.height);
    view.tag = 10 + index;
    [self addSubview:view];
}



/**
 两步认证，确定视图被回收
 @param index 目录
 */
-(void)twoStepVerificationReUseViewWithCurrentIndex:(NSInteger)index{
    for (UIView *view in self.subviews) {
        if ((view.tag < 10 + index - 1)||(view.tag > 10 + index + 1)) {
            [self enQueueWithView:view];
        }
    }
    [self deQueueView:index];
}


/**
 无动画非人工滚动专用
 1.移除添加view上的视图，并做清空操作
 2.缓存新的视图
 3.调用代理实现 willAppearOfView 和 didAppearOfView
 */
-(void)clearViewsForNoAnimation{
     __weak typeof (self) weakSelf = self;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf enQueueWithView:obj];
            if ([weakSelf.dataDelegate respondsToSelector:@selector(clearBeforeDecache:inthe:)]) {
                [_dataDelegate clearBeforeDecache:obj inthe:weakSelf];
            }
    }];
    

     [self deCacheViewWith:_currentIndex];
     UIView *currentView = [self viewWithTag:(10 + _currentIndex)];
    if (self.dataDelegate) {
        if ([_dataDelegate respondsToSelector:@selector(willAppearOfView:From:inthe:)]) {
             [ _dataDelegate willAppearOfView:currentView From:_realTimeIndex inthe:weakSelf];
             [ _dataDelegate didAppearOfView:currentView From:_realTimeIndex inthe:weakSelf];
        }
    }
    
    //恢复animation state
    _isAnimatedMove = @(true);
}

#pragma mark -- 滚动的代理事件，主要是水平手势滚动时会用到以下视图

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.isAnimatedMove.boolValue) {
        
        BOOL isForward = (scrollView.contentOffset.x -  _lastX) > 0 ? true :false;
        __weak typeof (self) weakSelf = self;
        NSInteger x =  scrollView.contentOffset.x;
        NSInteger width =  scrollView.frame.size.width;
        NSInteger page = (x + width - K_View_Appear_Active_Offset) / width;
        NSInteger nagativePage = (x + K_View_Appear_Active_Offset) / width;
        
        if (isForward) {
            if(page > _realTimeIndex){
                _realTimeIndex = page;
                if (page != _numberOfpage - 1) {
                    if (page - 2 >= 0) {
                        [self enQueueView:page -2];
                    }
                }
                if (page + 1 < self.numberOfpage) {
                    [self deCacheViewWith:page + 1];
                }
                
                
                if (_currentIndex == _realTimeIndex) {
                    return;
                }
                
                UIView *view;
                view = [scrollView viewWithTag:(10 + _realTimeIndex)];
                UIView *lastView = [scrollView viewWithTag:(10 + _currentIndex )];
                
                if ([_dataDelegate respondsToSelector:@selector(willAppearOfView:From:inthe:)]) {
                    [ _dataDelegate willAppearOfView:view From:_realTimeIndex inthe:weakSelf];
                }
                if ([_dataDelegate respondsToSelector:@selector(willDisAppearOfView:From:inthe:)])
                    [ _dataDelegate willDisAppearOfView:lastView From:_currentIndex inthe:weakSelf];
            }
            
        }else
        {
            
            if (nagativePage < _realTimeIndex) {
                _realTimeIndex = nagativePage;
                
                if (nagativePage != self.numberOfpage - 2){
                    
                    if (nagativePage + 2 < self.numberOfpage) {
                        [self  enQueueView:nagativePage + 2];
                    }
                    
                    if (nagativePage - 1 >= 0) {
                        [self deCacheViewWith:nagativePage - 1];
                    }
                    
                    
                }
                
                
                if (_currentIndex == _realTimeIndex) {
                    return;
                }
                
                UIView *view;
                view = [scrollView viewWithTag:(10 + _realTimeIndex)];
                UIView *lastView = [scrollView viewWithTag:(10 + _currentIndex)];
                
                
                if ([_dataDelegate respondsToSelector:@selector(willAppearOfView:From:inthe:)]) {
                    [ _dataDelegate willAppearOfView:view From:_realTimeIndex inthe:weakSelf];
                }
                if ([_dataDelegate respondsToSelector:@selector(willDisAppearOfView:From:inthe:)])
                    [ _dataDelegate willDisAppearOfView:lastView From:_currentIndex inthe:weakSelf];
            }
            
        }
        
        _lastX = scrollView.contentOffset.x;
        
    }
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //    NSLog(@"scroll' over");
    __weak typeof (self) weakSelf = self;
    
    
    if (self.isAnimatedMove.boolValue) {
        
        NSInteger x =  scrollView.contentOffset.x;
        NSInteger width =  scrollView.frame.size.width;
        //减5只是为了在目录等于0时可以响应
        NSInteger page = (x + width / 2) / width;
        
        //    if ((page - 1 )>= 0) {
        //         [self deCacheViewWith:page - 1];
        //    }
        //
        //    if ((page + 1) < self.numberOfpage) {
        //         [self deCacheViewWith:page + 1];
        //    }
        
        UIView *view = [scrollView viewWithTag:10 + page];
        UIView *lastView = [scrollView viewWithTag:10 + _currentIndex];
        
        if (_currentIndex != page) {
            
            if ([_dataDelegate respondsToSelector:@selector(didAppearOfView:From:inthe:)]) {
                if (!view) {
                    [self twoStepVerificationReUseViewWithCurrentIndex:page];
                    view = [scrollView viewWithTag:10 + page];
                }
                
                // 结束时恢复手势操作，解决平移时手势的干预
                self.panGestureRecognizer.enabled = true;
                [self setUserInteractionEnabled:true];
                [_dataDelegate didAppearOfView:view From:page inthe:weakSelf];
            }
            
            if ([_dataDelegate respondsToSelector:@selector(didDisAppearOfView:From:inthe:)]) {
                [_dataDelegate didDisAppearOfView:lastView From:_currentIndex inthe:weakSelf];
            }
            _currentIndex = page;
            _realTimeIndex = page;
        }
    }
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (self.isAnimatedMove.boolValue) {
        
        if (_currentIndex != _realTimeIndex)return;
        __weak typeof (self) weakSelf = self;
        self.panGestureRecognizer.enabled = true;
        [self setUserInteractionEnabled:true];
        if ([_dataDelegate respondsToSelector:@selector(didAppearOfView:From:inthe:)]) {
            UIView *view = [self viewWithTag:10 + _currentIndex];
            if (!view) {
                [self twoStepVerificationReUseViewWithCurrentIndex:_currentIndex];
                view = [scrollView viewWithTag:10 + _currentIndex];
            }
            NSLog(@"cccc %li  %li",_realTimeIndex,_currentIndex);
            [_dataDelegate didAppearOfView:view From:_currentIndex inthe:weakSelf];
        }
    }
}


#pragma mark -- 跳转相关

-(void)scrollToIndex:(NSInteger)index animated:(BOOL)isAnimated{
    self.isAnimatedMove = @(isAnimated);
    if (isAnimated) {
        
        //为了解决平移动画时手势的干预造成的bug
        if ((!_firstEnterFlag)||(_currentIndex == index)) {
            _firstEnterFlag = true;
        }
        else
        {
            self.panGestureRecognizer.enabled = false;
            [self setUserInteractionEnabled:false];
        }
        _currentIndex = index;
        [self setContentOffset:CGPointMake(self.bounds.size.width * index, 0) animated:isAnimated];
    }else{
        [self setContentOffset:CGPointMake(self.bounds.size.width * index, 0) animated:isAnimated];
        _currentIndex = index;
        _realTimeIndex = index;
        _lastX = self.contentOffset.x;
        [self clearViewsForNoAnimation];
    }
}


-(NSNumber *)isAnimatedMove{
    if (!_isAnimatedMove) {
        _isAnimatedMove = @(true);
    }
    return _isAnimatedMove;
}

-(void)dealloc {
    //NSLog(@"%@ already dealloc",NSStringFromClass([self class]));
}



@end
