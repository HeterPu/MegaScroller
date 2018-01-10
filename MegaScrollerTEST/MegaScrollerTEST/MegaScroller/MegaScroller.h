//
//  MegaScroller.h
//
//  Created by pi on 2017/6/13.
//  Copyright © 2017年 Peter Hu. All rights reserved.
//  Github HomePage: https://github.com/HeterPu/MegaScroller
//  Like It ,Star It !
//

#import <UIKit/UIKit.h>


/*
 Already Use Cacher for different kinds of prototype cell, Automatical manage cells reuse;
 */


@class MegaScroller;
/**
  特殊标记flag，方便标记复杂状态(Spetial Flag For Mark Complex Status)
 - MSTagStateDefalut: 默认加载(Default Load)
 - MSTagStateUnLoad: 未加载过flag(View Unload)
 - MSTagStateStrange: 加载异常flag(View LoadStrange)
 - MSTagStateDecached: 加载异常flag(View Cached)
 - MSTagStateAlreadyLoaded: 加载异常flag(View Already Loaded)
 */
typedef NS_ENUM(NSInteger,MSTagState){
    MSTagStateDefalut = -1,
    MSTagStateUnLoad = -2,
    MSTagStateStrange = -3,
    MSTagStateDecached = -4,
    MSTagStateAlreadyLoaded = -5,
};


/////////////////////  DATASOURCE ////////////////////////

/**
 MegaScroller dataSource
 */
@protocol MegaScrollerDataSource <NSObject>

/**
 (NumberOfPages)
 @param scroller (Current Scroller)
 @return number of pages
 */
-(NSInteger)numbersOfPageIn:(MegaScroller *)scroller;


/**
 Fetch PrototypeCell From index
 
 @param scroller (Current Scroller)
 @param index (index)
 @return PrototypeCell
 */
-(NSString *)protypeOf:(MegaScroller *)scroller from:(NSInteger) index;


@optional

/**
 Init Cell From Index
 
 @param mView cell
 @param scroller Current Scroller
 */
-(void)didInitOf:(UIView *)mView inthe:(MegaScroller *)scroller;


@end


///////////////////// DELEGATE ////////////////////////


/**
 MegaScroller dataDelegate
 */
@protocol MegaScrollerDelegate <NSObject>

@optional
/**
 View Will Appear
 
 @param mView cell
 @param index index
 @param scroller Current Scroller
 */
-(void)willAppearOfView:(UIView *)mView From:(NSInteger)index inthe:(MegaScroller *)scroller;

@optional
/**
View Did Appear

 @param mView cell
 @param index index
 @param scroller Current Scroller
 */
-(void)didAppearOfView:(UIView *)mView From:(NSInteger)index inthe:(MegaScroller *)scroller;

@optional
/**
View Will disappear

 @param mView cell
 @param index index
 @param scroller current scroller
 */
-(void)willDisAppearOfView:(UIView *)mView From:(NSInteger)index inthe:(MegaScroller *)scroller;

@optional
/**
(View Already Disappear)
 @param mView cell
 @param index index
 @param scroller Current Scroller
 */
-(void)didDisAppearOfView:(UIView *)mView From:(NSInteger)index inthe:(MegaScroller *)scroller;

@optional
/**
 (Clear Before view Cached)
 @param mView mview(View gonna to be cached)
 @param scroller Current scroller
 */
-(void)clearBeforeDecache:(UIView *)mView inthe:(MegaScroller *)scroller;

@end



@interface MegaScroller : UIScrollView


/**
 Megascroller

 @param frame scroller frame
 @param delegate contain datasource & datedelagate
 @param initialIndex Initail Index,
 @return instance
 */
+(instancetype)megaScrollerWithframe:(CGRect)frame andDelegate:(id<MegaScrollerDataSource,MegaScrollerDelegate>)delegate initialIndex:(NSInteger)initialIndex;


/**
 ScrollToIndex

 @param index index
 @param isAnimated is EXCUTE animation scroll.
 */
-(void)scrollToIndex:(NSInteger)index animated:(BOOL)isAnimated;


@end
