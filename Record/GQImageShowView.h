//
//  GQImageShowView.h
//  AMAP3DDemo
//
//  Created by Lidear on 15/11/27.
//  Copyright © 2015年 zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  GQ - 图片展示view
 *      图片高度为view高度减去 8*2
 */
@interface GQImageShowView : UIView

@property (nonatomic, strong) NSMutableArray *showImgArr;
@property (nonatomic, assign) BOOL isNeedAddBtn;            //  开启添加按钮
@property (nonatomic, assign) BOOL isNeedDeleteBtn;         //  开启关闭按钮


/**
 *  点击添加图片
 */
@property (nonatomic, copy) dispatch_block_t blockClickAdd;

/**
 *  点击图片
 */
@property (nonatomic, copy) dispatch_block_t blockClickImage;

/**
 *  点击删除按钮
 */
@property (nonatomic, strong) void (^blockDeleteCallBack) (NSMutableArray *images);


/**
 *  设置images 传入image数组
 */
- (void)addImages:(NSMutableArray *)images;

/**
 *  设置images 传入image数组
 */
- (void)addImageURLs:(NSMutableArray *)imageURLs;

@end
